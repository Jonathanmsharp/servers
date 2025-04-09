@echo off
echo Starting all MCP servers...

:: Start mem0 server
echo Starting mem0 server...
start "" "C:\Users\jonathan.sharp\OneDrive - Kisco Senior Living\Documents\Git\servers\mem0-mcp\Launch_mem0_server.bat"

:: Start code sandbox server
echo Starting code sandbox server...
start "" "C:\Users\jonathan.sharp\OneDrive - Kisco Senior Living\Documents\Git\servers\mcp-code-sandbox\run_server.bat"

:: Start MSSQL server in SSE mode on port 8083
echo Starting MSSQL server in SSE mode...
start "" "C:\Users\jonathan.sharp\OneDrive - Kisco Senior Living\Documents\Git\servers\mssql_mcp_server\run_mssql_server.bat" 1 8081



echo All servers started. Check individual windows for status. 