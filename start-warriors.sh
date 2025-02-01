#!/bin/bash

# Ask for number of warriors
read -p "How many warrior instances? " num_warriors

# Generate the compose file
echo "$num_warriors" | ./howmanyusgvt.sh

# Start watchtower first
docker-compose -f warriorsusgvt.yml up -d archiveteam-watchtower
echo "Started watchtower, waiting 10 seconds for initialization..."
sleep 10

# Start warriors in pairs
for i in $(seq 1 2 $num_warriors); do
    # Check if this is the last number and it's odd
    if [ $i -eq $num_warriors ]; then
        echo "Starting warrior $i..."
        docker-compose -f warriorsusgvt.yml up -d archiveteam-warrior-$i
    else
        j=$((i+1))
        echo "Starting warriors $i and $j..."
        docker-compose -f warriorsusgvt.yml up -d archiveteam-warrior-$i archiveteam-warrior-$j
    fi

    # Don't sleep after the last pair/single
    if [ $i -lt $num_warriors ]; then
        echo "Waiting 30 seconds before next pair..."
        sleep 30
    fi
done

# Clean up any orphans at the end
echo "Cleaning up orphans..."
docker-compose -f warriorsusgvt.yml up -d --remove-orphans
echo "Deployment complete!"
