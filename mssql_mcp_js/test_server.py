import os
import sys

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)
    
    # Test database connection
    from db_connection_pool import DatabaseConnectionPool
    try:
        pool = DatabaseConnectionPool()
        conn = pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        result = cursor.fetchone()
        cursor.close()
        pool.return_connection(conn)
        print("Database connection test: SUCCESS")
    except Exception as e:
        print(f"Database connection test: FAILED - {str(e)}")
        return

    print("All tests passed. Server should be ready to run.")

if __name__ == "__main__":
    main()