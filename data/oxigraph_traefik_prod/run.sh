#touch acme.json
#chmod 600 config/acme.json

# Generate Password Hash (Optional - if you want to change it)
#docker run --rm httpd:2.4-alpine htpasswd -nbB admin "your-password" | cut -d ":" -f 2
#htpasswd -nB admin > config/.htpasswd

#docker compose down -v
docker compose down
#docker compose up -d reverse-proxy
#docker compose up -d whoami

# Deploy local quad store file
#docker run --rm \
#  -v ~/test/data/data:/data \
#  -v ~/test/data/upload:/upload \
#  oxigraph/oxigraph:0.4 \
#  load -l /data -f /upload/kb.pz.2025-04-14_0307_UTC-4.nq --base https://data.archives.gov.on.ca --format "application/n-quads"

docker compose up -d

# Back up data dir
#docker exec -it oxigraph /usr/local/bin/oxigraph backup -l /data -d /backup

# Check available disk space
#df -h

# Add latest Description triples into a graph via store
#curl -X POST \
#  -H 'Content-Type:application/n-triples' \
#  -T "/mnt/c/Users/Anonymous/Workshop/202312161720UTC-5_RA_at_GLAM_Incubator/Some_files_from_OneDrive_2025-03-17_onward/DESCRIPTION_preprocessed_mapped_postprocessed_2025-03-18_1337.nt" \
#  "https://data.test.gbad.ca/store?graph=https://data.archives.gov.on.ca/TriG/DESCRIPTION_preprocessed_mapped_postprocessed.PZ.2025-03-18" \
#  -k -u walkerton \
#  -v -o /dev/null -w "HTTP status: %{http_code}\n"

# Add latest Authority triples into a graph via store
#curl -X POST \
#  -H 'Content-Type:text/turtle' \
#  -T "/mnt/c/Users/Anonymous/Workshop/202312161720UTC-5_RA_at_GLAM_Incubator/Some_files_from_OneDrive_2025-03-17_onward/AUTHORITY_preprocessed_csv_mapped_2025-04-11.ttl" \
#  "https://data.test.gbad.ca/store?graph=https://data.archives.gov.on.ca/TriG/AUTHORITY_preprocessed_csv_mapped.PZ.2025-04-11" \
#  -k -u walkerton \
#  -v -o /dev/null -w "HTTP status: %{http_code}\n"
