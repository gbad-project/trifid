# Save this as test_server.py
import http.server
import socketserver
import os
from dotenv import load_dotenv

# Load environment variables from file
load_dotenv(".env.local")

UNENCRYPTED_PORT = int(os.getenv("UNENCRYPTED_PORT"))
LOCALHOST = os.getenv("LOCALHOST")
Handler = http.server.SimpleHTTPRequestHandler

# Calculate the path to the www directory relative to the script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WWW_DIR = os.path.join(SCRIPT_DIR, os.getenv("PUBLIC_HTML"))

# Create a handler that serves from the www directory
class WWWDirectoryHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        # Set the directory to serve files from
        super().__init__(*args, directory=WWW_DIR, **kwargs)

httpd = socketserver.TCPServer((LOCALHOST, UNENCRYPTED_PORT), WWWDirectoryHandler)
print(f"Server running on http://{LOCALHOST}:{UNENCRYPTED_PORT}")
httpd.serve_forever()
