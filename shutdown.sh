#!/bin/bash

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPT_DIR

function save {
    container_name=$1

    # Get container ID of the running instance
    container_ID=$(docker ps | grep "$container_name" | awk '{ print $1 }')

    if [ ! -z "$container_ID" ]; then
        # Saving container state
        echo "[$container_name|$container_ID] Saving container state"
        docker commit $container_ID vigor
    fi
}

save "vigor"
save "synapse"

# Bringing containers down
docker-compose down > /dev/null 2>&1
