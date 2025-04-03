docker run  --rm -it \
    -p 7878:7878 \
    -v oxigraph-data:/data \
    oxigraph/oxigraph:latest serve \
    --location /data
