import asyncio
from mcp.client.fastmcp import FastMCPClient  # Updated import

async def main():
    # Connect to the MCP server
    client = FastMCPClient()  # Using FastMCPClient instead of MCPClient
    await client.connect()
    
    try:
        # Test 1: List all tables
        print("\nListing tables:")
        result = await client.call("list_tables")
        print(result)
        
        # Test 2: Execute a simple query
        print("\nExecuting simple query:")
        query = "SELECT TOP 5 * FROM INFORMATION_SCHEMA.TABLES"
        result = await client.call("execute_query", query=query)
        print(result)
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        await client.close()

if __name__ == "__main__":
    asyncio.run(main())
