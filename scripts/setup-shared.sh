#!/usr/bin/bash

set -euo pipefail

shared=/home/synapse/.shared
workspace=/home/synapse/vigor

if [ -z "$(ls -A $shared)" ]; then
    # Shared folder is empty, so let's use copy all the boilerplate to the shared folder
    echo "Setting up shared folder, this might take a bit..."
    sudo cp -r $vigor/* $shared/
    echo "Done!"
fi

# Point the container workspace to the shared folder
sudo rm -rf $vigor
ln -s $shared $vigor
