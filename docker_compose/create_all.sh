docker network create --driver bridge web

for file in /mnt/server/Serversetup/docker_compose/*.yaml; do
    echo "Processing $file"
    docker compose -f "$file" up -d 
done