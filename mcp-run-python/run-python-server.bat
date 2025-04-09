@echo off
:: Set environment variables
set PORT=3001
set HOST=127.0.0.1

:: Run the server
echo Starting Python MCP server on %HOST%:%PORT%...
npx @pydantic/mcp-run-python sse

:: Keep the window open if there's an error
if errorlevel 1 pause 