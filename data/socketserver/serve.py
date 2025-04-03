# Originally generated with Claude 3.7 Sonnet on 2025-04-02, modified

import http.server
import socketserver
import ssl
import os
from dotenv import load_dotenv

# Load environment variables from file
load_dotenv(".env.local")

# Server configuration
ENCRYPTED_PORT = os.getenv("ENCRYPTED_PORT")
UNENCRYPTED_PORT = os.getenv("UNENCRYPTED_PORT")
LOCALHOST = os.getenv("LOCALHOST")
CERTFILE = os.getenv("CERTFILE")  # Combined certificate and key file

# Calculate the path to the www directory relative to the script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WWW_DIR = os.path.join(SCRIPT_DIR, os.getenv("PUBLIC_HTML"))

# Create a handler that serves from the www directory
class WWWDirectoryHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        # Set the directory to serve files from
        super().__init__(*args, directory=WWW_DIR, **kwargs)

# Create a basic request handler
class MyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(b"<html><body><h1>Secure Python Server</h1><p>This is a secure HTTPS server running on Python 12.</p></body></html>")

# Set up the server
httpd = socketserver.ThreadingTCPServer((LOCALHOST, UNENCRYPTED_PORT), WWWDirectoryHandler)

# Wrap with SSL
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile=CERTFILE)
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

# Start the server
print(f"Server running on https://{LOCALHOST}:{ENCRYPTED_PORT}")
try:
    httpd.serve_forever()
except KeyboardInterrupt:
    print("\nServer stopped.")
    httpd.server_close()
