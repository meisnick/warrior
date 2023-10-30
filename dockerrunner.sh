#!/bin/bash

# Function to check if a container is running
is_container_running() {
    local name="$1"
    docker ps -f "name=${name}" | grep -w "${name}" > /dev/null 2>&1
}

# Ensure archiveteam-watchtower is running
if ! is_container_running "archiveteam-watchtower"; then
    docker-compose up -d archiveteam-watchtower
fi

# Ensure 5 archiveteam-warrior instances are running
for i in $(seq 1 5); do
    container_name="archiveteam-warrior-${i}"

    if ! is_container_running "${container_name}"; then
        docker start "${container_name}"
    fi
done
