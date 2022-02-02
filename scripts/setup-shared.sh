#!/usr/bin/bash

set -euo pipefail

shared=/home/snap/.shared
workspace=/home/snap/vigor

if [ -z "$(ls -A $shared)" ]; then
    # Shared folder is empty, so let's use copy all the boilerplate to the shared folder
    echo "Setting up shared folder, this might take a bit..."
    sudo cp -r $workspace/* $shared/
    sudo chown -R snap:snap $shared/
    echo "Done!"
fi

# Point the container workspace to the shared folder
sudo rm -rf $workspace
ln -s $shared $workspace
