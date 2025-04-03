docker run --rm -it \
    -p 8080:8080 \
    --add-host=host.docker.internal:host-gateway \
    --env-file .env.local \
    -v "/mnt/c/home/anonymous/ao-gbad-trifid/instances/gbad/config.yaml:/instances/gbad/config.yaml" \
    -v "/mnt/c/home/anonymous/ao-gbad-trifid/instances/gbad/welcome.hbs:/instances/gbad/welcome.hbs" \
    -v "/mnt/c/home/anonymous/ao-gbad-trifid/instances/gbad/render.hbs:/instances/gbad/render.hbs" \
    -v "/mnt/c/home/anonymous/ao-gbad-trifid/data/www/statements.trig:/data/statements.trig" \
    ghcr.io/zazuko/trifid
