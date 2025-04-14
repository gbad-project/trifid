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
#docker-compose -f compose.test.yml --env-file myvars.env down
docker-compose -f compose.test.yml down

# Load initial trig for speed
docker run --rm \
  -v /mnt/c/home/anonymous/ao-gbad-trifid/data/oxigraph/data:/data \
  -v /mnt/c/home/anonymous/ao-gbad-trifid/data/www:/upload \
  oxigraph/oxigraph:0.4 \
  load -l /data -f /upload/statements.trig --base https://data.archives.gov.on.ca

#docker compose up -d reverse-proxy
#docker compose up -d whoami
docker compose -f compose.test.yml up -d

# Enter the Caddy container
#docker exec -it traefik sh

# Install tools if needed
#apk add --no-cache curl iputils

# Check connectivity to Oxigraph
#ping oxigraph
#curl http://oxigraph:7878

#curl -k -u admin:secure_password https://localhost:8443

# Test add triples into graph via store
#curl -X POST \
#  -H 'Content-Type:application/n-triples' \
#  -T /mnt/c/home/anonymous/ao-gbad-trifid/data/www/mapped_postprocessed.nt \
#  "https://localhost:8443/store?graph=http://example.com/g" \
#  -k -u admin \
#  -s -o /dev/null -w "HTTP status: %{http_code}\n"

# Test replace entire quadstore - works but is VERY slow
#curl -X PUT \
#  -H 'Content-Type:application/trig' \
#  -T /mnt/c/home/anonymous/ao-gbad-trifid/data/www/statements.trig \
#  "https://localhost:8443/store" \
#  -k -u admin \
#  -v -o /dev/null -w "HTTP status: %{http_code}\n"

# COMPLETE WIPE of the quadstore
#curl -X POST https://localhost:8443/update   -H "Content-Type: application/sparql-update"   --data 'CLEAR ALL' -k -u admin -v -o /dev/null -w "HTTP status: %{http_code}\n"

# This should load data via CLI, but /data folder may be locked once served
#docker exec -it oxigraph /usr/local/bin/oxigraph load -l /data -f /upload/statements.trig --base https://data.archives.gov.on.ca

# List available commands - note that no sh in this image
#docker exec -it oxigraph /usr/local/bin/oxigraph help
# Expected output:
# Oxigraph CLI tool and SPARQL HTTP server
#
#
#Usage: oxigraph <COMMAND>
#
#Commands:
#  serve            Start Oxigraph HTTP server in read-write mode
#  serve-read-only  Start Oxigraph HTTP server in read-only mode
#  backup           Create a database backup into a target directory
#  load             Load file(s) into the store
#  dump             Dump the store content into a file
#  query            Execute a SPARQL query against the store
#  update           Execute a SPARQL update against the store
#  optimize         Optimize the database storage
#  convert          Convert a RDF serialization from one format to an other
#  help             Print this message or the help of the given subcommand(s)

#docker exec -it oxigraph /usr/local/bin/oxigraph load -h
#Load file(s) into the store
#
#Usage: oxigraph load [OPTIONS] --location <LOCATION>
#
#Options:
#  -l, --location <LOCATION>  Directory in which Oxigraph data are persisted
#  -f, --file [<FILE>...]     File(s) to load
#      --format <FORMAT>      The format of the file(s) to load
#      --base <BASE>          Base IRI of the file(s) to load
#      --lenient              Attempt to keep loading even if the data file is invalid
#      --graph <GRAPH>        Name of the graph to load the data to
#  -h, --help                 Print help (see more with '--help')

#docker exec -it oxigraph /usr/local/bin/oxigraph backup -h
#Create a database backup into a target directory
#
#Usage: oxigraph backup --location <LOCATION> --destination <DESTINATION>
#
#Options:
#  -l, --location <LOCATION>        Directory in which Oxigraph data are persisted
#  -d, --destination <DESTINATION>  Directory in which the backup will be written
#  -h, --help                       Print help (see more with '--help')

#docker exec -it oxigraph /usr/local/bin/oxigraph dump -h
#Dump the store content into a file
#
#Usage: oxigraph dump [OPTIONS] --location <LOCATION>
#
#Options:
#  -l, --location <LOCATION>  Directory in which Oxigraph data are persisted
#  -f, --file <FILE>          File to dump to
#      --format <FORMAT>      The format of the file(s) to dump
#      --graph <GRAPH>        Name of the graph to dump
#  -h, --help                 Print help (see more with '--help')docker exec -it oxigraph /usr/local/bin/oxigraph dump -h
