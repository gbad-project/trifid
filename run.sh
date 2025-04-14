docker run --rm -it \
    -p 8080:8080 \
    --add-host=host.docker.internal:host-gateway \
    --env-file .env.local \
    -v "/mnt/c/home/anonymous/ao-gbad-trifid/instances/gbad/config.yaml:/instances/gbad/config.yaml" \
    -v "/mnt/c/home/anonymous/ao-gbad-trifid/instances/gbad/welcome.hbs:/instances/gbad/welcome.hbs" \
    -v "/mnt/c/home/anonymous/ao-gbad-trifid/instances/gbad/render.hbs:/instances/gbad/render.hbs" \
    -v "/mnt/c/Users/Anonymous/Workshop/202312161720UTC-5_RA_at_GLAM_Incubator/Some_files_from_OneDrive_2025-03-17_onward/merged/kb.pz.2025-04-14_0307_UTC-4.nq:/upload/store.nq" \
    ghcr.io/zazuko/trifid
