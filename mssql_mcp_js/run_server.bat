@echo off
setlocal EnableDelayedExpansion

REM ========================================================
REM MCP Server Runner
REM ========================================================

echo Starting MCP Server...

REM Set the working directory to the script's location
cd /d "%~dp0"

REM Create and activate virtual environment if it doesn't exist
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install requirements
echo Installing dependencies...
python -m pip install -r requirements.txt

REM Set PYTHONPATH to include the current directory
set "PYTHONPATH=%CD%"

REM Debug: Print current directory and Python path
echo Working Directory: %CD%
echo PYTHONPATH: %PYTHONPATH%
echo.

REM Run the server directly with full path
echo Starting server (Press Ctrl+C to stop)...
python "%CD%\mcp_server.py"
echo.
echo Server stopped. Press R to restart or any other key to exit.
choice /c RQ /n /m "R=Restart, Q=Quit"
if errorlevel 2 goto :end
if errorlevel 1 goto :server_loop

:end
echo Shutting down...
deactivate
pause


