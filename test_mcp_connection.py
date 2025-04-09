import pymssql
import os
from dotenv import load_dotenv

def test_connection():
    load_dotenv()
    
    try:
        conn = pymssql.connect(
            server="ksldb252-2",
            user="BI_Agent",
            password="Id%dr*4rmTfX^hP",
            database="staging"
        )
        
        cursor = conn.cursor()
        cursor.execute("SELECT @@VERSION")
        row = cursor.fetchone()
        print("Connection successful!")
        print(f"SQL Server version: {row[0]}")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"Connection failed: {str(e)}")

if __name__ == "__main__":
    test_connection()