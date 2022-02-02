#!/usr/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd $SCRIPT_DIR

echo "[*] Setting up shared environment"
rm -rf shared > /dev/null 2>&1
mkdir -p shared

echo "[*] Building SNAP container"
docker-compose build snap
