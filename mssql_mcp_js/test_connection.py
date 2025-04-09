from db_connection_pool import DatabaseConnectionPool

def test_connection():
    print("Testing database connection pool...")
    try:
        # Create connection pool
        pool = DatabaseConnectionPool()
        print("Successfully created connection pool")
        
        # Get a connection
        conn = pool.get_connection()
        print("Successfully got connection from pool")
        
        # Test query
        cursor = conn.cursor()
        cursor.execute("SELECT @@VERSION")
        result = cursor.fetchone()
        print(f"SQL Server version: {result[0]}")
        
        # Return connection to pool
        cursor.close()
        pool.return_connection(conn)
        print("Successfully returned connection to pool")
        
        # Close all connections
        pool.close_all()
        print("Successfully closed all connections")
        
        print("\nAll connection pool tests passed!")
        
    except Exception as e:
        print(f"Error during test: {str(e)}")

if __name__ == "__main__":
    test_connection()
