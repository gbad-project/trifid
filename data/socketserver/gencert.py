# Originally generated with Claude 3.7 Sonnet on 2025-04-02, modified

# Generate a self-signed certificate (run this separately)
from OpenSSL import crypto
import os
from dotenv import load_dotenv

# Load environment variables from file
load_dotenv(".env.local")

def create_self_signed_cert(certfile):
    # Create a key pair
    k = crypto.PKey()
    k.generate_key(crypto.TYPE_RSA, 2048)
    
    # Create a self-signed cert
    cert = crypto.X509()
    cert.get_subject().C = os.getenv("C")
    cert.get_subject().ST = os.getenv("ST")
    cert.get_subject().L = os.getenv("L")
    cert.get_subject().O = os.getenv("O")
    cert.get_subject().OU = os.getenv("OU")
    cert.get_subject().CN = os.getenv("CN")
    cert.set_serial_number(1000)
    cert.gmtime_adj_notBefore(0)
    cert.gmtime_adj_notAfter(10*365*24*60*60)  # 10 years
    cert.set_issuer(cert.get_subject())
    cert.set_pubkey(k)
    cert.sign(k, 'sha256')
    
    # Write certificate and key to file
    with open(certfile, "wb") as f:
        f.write(crypto.dump_privatekey(crypto.FILETYPE_PEM, k))
        f.write(crypto.dump_certificate(crypto.FILETYPE_PEM, cert))
    
    print(f"Self-signed certificate created: {certfile}")

# Create the certificate if it doesn't exist
CERTFILE = os.getenv("CERTFILE")
if not os.path.exists(CERTFILE):
    create_self_signed_cert(CERTFILE)
