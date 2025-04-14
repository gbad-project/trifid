#touch acme.json
#chmod 600 config/acme.json

# Generate Password Hash (Optional - if you want to change it)
#docker run --rm httpd:2.4-alpine htpasswd -nbB admin "your-password" | cut -d ":" -f 2
#htpasswd -nB admin > config/.htpasswd

#docker-compose down -v
#docker-compose down
#docker compose up -d reverse-proxy
#docker compose up -d whoami
docker compose up -d
