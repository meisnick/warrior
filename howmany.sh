#!/bin/bash

read -p "How many warrior instances? " num

cat <<EOF > warriors.yml
version: "3.7"

services:

  archiveteam-watchtower:
    container_name: archiveteam-watchtower
    image: containrrr/watchtower
    labels:
      - com.centurylinklabs.watchtower.enable=true
    volumes:
      - '/var/run/docker.sock:/var/run/docker.sock'
    command: '--label-enable --cleanup --interval 3600' 
    restart: unless-stopped

EOF

for ((i=1;i<=$num;i++)); do
  port=$((8000 + i))
  cat <<EOF >> warriors.yml

  archiveteam-warrior-$i:
    container_name: archiveteam-warrior-$i
    image: atdr.meo.ws/archiveteam/warrior-dockerfile
    environment:
      - DOWNLOADER=meisnick
      - SELECTED_PROJECT=urlteam2
      - CONCURRENT_ITEMS=6
    stop_signal: SIGINT
    stop_grace_period: 5m 
    labels:
      - com.centurylinklabs.watchtower.enable=true
    ports:
      - '$port:8001'
    restart: unless-stopped

EOF
done
