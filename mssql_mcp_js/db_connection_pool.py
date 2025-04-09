import pymssql  # Make sure we're using pymssql
from queue import Queue
from threading import Lock
import time
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv(override=True)  # Added override=True to ensure values are loaded

class DatabaseConnectionPool:
    def __init__(self, pool_size=None):
        self.pool_size = pool_size or int(os.getenv('DB_POOL_SIZE', 5))
        self.pool = Queue(maxsize=self.pool_size)
        self.lock = Lock()
        
        # Debug: Print connection parameters
        print("\nConnection Parameters:")
        print(f"Server: {os.getenv('DB_SERVER')}")
        print(f"Database: {os.getenv('DB_NAME')}")
        print(f"User: {os.getenv('DB_USER')}")
        print(f"Password: {'*****' if os.getenv('DB_PASSWORD') else 'Not Set'}")
        print(f"Pool Size: {self.pool_size}")
        
        self.initialize_pool()

    def _create_connection(self):
        """Create a new database connection"""
        try:
            server = os.getenv('DB_SERVER')
            user = os.getenv('DB_USER')
            password = os.getenv('DB_PASSWORD')
            database = os.getenv('DB_NAME')
            
            if not all([server, user, password, database]):
                raise ValueError("Missing required database configuration")
                
            return pymssql.connect(
                server=server,
                user=user,
                password=password,
                database=database
            )
        except pymssql.Error as e:
            print(f"Error creating connection: {e}")
            raise
        except Exception as e:
            print(f"Unexpected error: {e}")
            raise

    def initialize_pool(self):
        """Initialize the connection pool with the specified number of connections"""
        for _ in range(self.pool_size):
            connection = self._create_connection()
            self.pool.put(connection)

    def get_connection(self, timeout=30):
        """Get a connection from the pool"""
        try:
            connection = self.pool.get(timeout=timeout)
            if not self._is_connection_valid(connection):
                connection = self._create_connection()
            return connection
        except Exception as e:
            print(f"Error getting connection: {e}")
            raise

    def return_connection(self, connection):
        """Return a connection to the pool"""
        try:
            if self._is_connection_valid(connection):
                self.pool.put(connection)
            else:
                connection = self._create_connection()
                self.pool.put(connection)
        except Exception as e:
            print(f"Error returning connection: {e}")
            raise

    def _is_connection_valid(self, connection):
        """Check if a connection is valid"""
        try:
            cursor = connection.cursor()
            cursor.execute("SELECT 1")
            cursor.close()
            return True
        except:
            return False

    def close_all(self):
        """Close all connections in the pool"""
        while not self.pool.empty():
            try:
                connection = self.pool.get_nowait()
                connection.close()
            except:
                pass


