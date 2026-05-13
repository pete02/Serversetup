docker network create --driver bridge web
docker compose -f portainer.yaml up -d
docker compose -f mongo.yaml up -d
docker compose -f traefik.yaml up -d
docker compose -f vaultwarden.yaml up -d
docker compose -f ubiqiti.yaml up -d
docker compose -f porkbunddns.yaml up -d
docker compose -f booklegion.yaml up -d --pull always