# Create the connection pool
pool = DatabaseConnectionPool()

# Example usage
try:
    # Get a connection from the pool
    conn = pool.get_connection()
    
    # Use the connection
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM your_table")
    results = cursor.fetchall()
    
    # Close cursor
    cursor.close()
    
    # Return the connection to the pool
    pool.return_connection(conn)
    
except Exception as e:
    print(f"Error: {e}")
finally:
    # Close all connections when done
    pool.close_all()