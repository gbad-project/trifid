# Generate a Self-Signed Certificate for Local HTTPS
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#  -keyout config/local-key.pem \
#  -out config/local-cert.pem \
#  -subj "/CN=localhost"

#touch acme.json
#chmod 600 acme.json

# Generate Password Hash (Optional - if you want to change it)
#docker run --rm httpd:2.4-alpine htpasswd -nbB admin "your-password" | cut -d ":" -f 2
#htpasswd -nB admin > config/.htpasswd

#docker-compose down -v
docker-compose -f docker-compose.test.yml down
#docker compose up -d reverse-proxy
#docker compose up -d whoami
docker compose -f docker-compose.test.yml up -d

# Enter the Caddy container
#docker exec -it traefik sh

# Install tools if needed
#apk add --no-cache curl iputils

# Check connectivity to Oxigraph
#ping oxigraph
#curl http://oxigraph:7878

#curl -k -u admin:secure_password https://localhost:8443
