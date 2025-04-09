import os
import sys
import asyncio
import logging
from mcp.server.fastmcp import FastMCP
from mcp.types import Resource, Tool, TextContent
from db_connection_pool import DatabaseConnectionPool

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Configure server using FastMCP
app = FastMCP("mssql_mcp_server")
pool = DatabaseConnectionPool()

@app.tool()
async def execute_query(query: str, params: list = None) -> dict:
    """Execute a SQL query and return results"""
    try:
        conn = pool.get_connection()
        cursor = conn.cursor()
        
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
            
        results = cursor.fetchall()
        cursor.close()
        pool.return_connection(conn)
        
        return {"status": "success", "data": results}
    except Exception as e:
        logger.error(f"Query error: {str(e)}")
        return {"status": "error", "message": str(e)}

@app.tool()
async def list_tables() -> dict:
    """List all available tables"""
    try:
        conn = pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT TABLE_SCHEMA, TABLE_NAME 
            FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_TYPE = 'BASE TABLE'
        """)
        tables = cursor.fetchall()
        cursor.close()
        pool.return_connection(conn)
        
        return {
            "status": "success",
            "tables": [{"schema": t[0], "name": t[1]} for t in tables]
        }
    except Exception as e:
        logger.error(f"Tables error: {str(e)}")
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    try:
        # Print startup message
        print("=" * 50)
        print("MCP SQL Server Starting...")
        print("=" * 50)
        print("\nPress Ctrl+C to stop the server\n")
        
        # Run the server with stdio transport (recommended for Augment)
        app.run("stdio")
        
    except KeyboardInterrupt:
        logger.info("Server stopped by user")
    except Exception as e:
        logger.error(f"Server error: {str(e)}")
        sys.exit(1)
    finally:
        print("\nServer shutdown complete")






