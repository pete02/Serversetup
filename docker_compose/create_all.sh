docker network create --driver bridge web
docker compose -f portainer.yaml up -d
docker compose -f traefik.yaml up -d
docker compose -f vaultwarden.yaml up -d
docker-compose up -f booklegion.yaml -d --pull always