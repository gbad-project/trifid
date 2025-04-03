# Originally generated with Claude 3.7 Sonnet on 2025-04-02, modified

import http.server
import socketserver
import ssl
import os
import urllib.request  # For forwarding requests
from dotenv import load_dotenv

# Load environment variables from file
load_dotenv(".env.local")

# Server configuration
CERTFILE = os.getenv("CERTFILE")  # Combined certificate and key file
HTTP_BACKEND = os.getenv("HTTP_BACKEND")  # Your HTTP backend
LOCALHOST = os.getenv("LOCALHOST")
ENCRYPTED_PORT = os.getenv("ENCRYPTED_PORT")

class ReverseProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            # Forward the request to the HTTP backend
            backend_url = f"{HTTP_BACKEND}{self.path}"
            with urllib.request.urlopen(backend_url) as response:
                self.send_response(response.status)
                # Copy headers from backend
                for header, value in response.headers.items():
                    self.send_header(header, value)
                self.end_headers()
                # Stream the response body
                self.wfile.write(response.read())
        except Exception as e:
            self.send_error(500, f"Proxy error: {str(e)}")

# Set up SSL server

httpd = socketserver.ThreadingTCPServer((LOCALHOST, ENCRYPTED_PORT), ReverseProxyHandler)
context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile=CERTFILE)
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

print(f"Reverse proxy running on https://{LOCALHOST}:{ENCRYPTED_PORT} → {HTTP_BACKEND}")
try:
    httpd.serve_forever()
except KeyboardInterrupt:
    print("\nServer stopped.")
    httpd.server_close()
