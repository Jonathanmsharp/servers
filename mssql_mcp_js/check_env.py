from pathlib import Path
import os

env_path = Path('.env')
print(f"Current directory: {os.getcwd()}")
print(f".env file exists: {env_path.exists()}")

if env_path.exists():
    print("\nContents of .env file:")
    with open('.env', 'r') as f:
        print(f.read())