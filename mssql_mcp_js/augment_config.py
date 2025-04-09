from db_connection_pool import DatabaseConnectionPool

def get_db_pool():
    """Get a singleton instance of the database connection pool"""
    if not hasattr(get_db_pool, 'pool'):
        get_db_pool.pool = DatabaseConnectionPool()
    return get_db_pool.pool

def execute_query(query, params=None):
    """Execute a query using the connection pool"""
    pool = get_db_pool()
    connection = pool.get_connection()
    try:
        cursor = connection.cursor()
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
        return results
    finally:
        pool.return_connection(connection)

def execute_command(command, params=None):
    """Execute a command (INSERT, UPDATE, DELETE) using the connection pool"""
    pool = get_db_pool()
    connection = pool.get_connection()
    try:
        cursor = connection.cursor()
        if params:
            cursor.execute(command, params)
        else:
            cursor.execute(command)
        connection.commit()
        cursor.close()
    finally:
        pool.return_connection(connection)