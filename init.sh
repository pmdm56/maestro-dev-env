#!/usr/bin/bash

set -euo pipefail

echo "[*] Setting up shared environment"
rm -rf shared > /dev/null 2>&1
mkdir -p shared

echo "[*] Building container"
docker-compose build

echo "[*] Spinning up the container"
docker-compose up -d
