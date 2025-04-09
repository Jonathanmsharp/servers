import pymssql
import os
from dotenv import load_dotenv, find_dotenv
from pathlib import Path

# Print current working directory
print(f"Current working directory: {os.getcwd()}")

# Find and load .env file
env_path = find_dotenv(raise_error_if_not_found=True)
print(f"Found .env at: {env_path}")
load_dotenv(env_path, override=True)  # Added override=True to ensure values are loaded

def test_simple_connection():
    # Print all relevant environment variables
    print("\nEnvironment Variables after loading:")
    server = os.getenv('DB_SERVER')
    user = os.getenv('DB_USER')
    password = os.getenv('DB_PASSWORD')
    database = os.getenv('DB_NAME')
    
    print(f"DB_SERVER: {server}")
    print(f"DB_USER: {user}")
    print(f"DB_PASSWORD: {'*****' if password else 'Not Set'}")
    print(f"DB_NAME: {database}")
    
    if not all([server, user, password, database]):
        print("\nError: Some environment variables are not set!")
        return
    
    try:
        conn = pymssql.connect(
            server=server,
            user=user,
            password=password,
            database=database
        )
        print("\nConnection successful!")
        
        cursor = conn.cursor()
        cursor.execute("SELECT @@VERSION")
        row = cursor.fetchone()
        print(f"SQL Server version: {row[0]}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"\nConnection failed: {str(e)}")

if __name__ == "__main__":
    test_simple_connection()


