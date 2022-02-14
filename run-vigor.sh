#!/bin/bash

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd $SCRIPT_DIR

function setup {
    # Creating shared folder
    rm -rf shared > /dev/null 2>&1
    mkdir -p shared

    # Building SNAP container
    docker-compose build snap

    # Building the vigor container
    docker-compose build vigor
}

# Check if shared directory doesn't exist or is empty
if [ ! -d $SCRIPT_DIR/shared ] || [ -z "$(ls -A $SCRIPT_DIR/shared)" ]; then
    setup
fi

docker-compose up -d vigor
docker-compose exec vigor zsh