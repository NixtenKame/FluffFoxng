This directory stores Traefik ACME storage (acme.json).
When starting Traefik for the first time, create an empty file and secure it:

    mkdir -p docker/traefik
    touch docker/traefik/acme.json
    chmod 600 docker/traefik/acme.json

Traefik will write certificates into this file when Let's Encrypt issues them.
