#!/usr/bin/bash

set -euo pipefail

rm -rf shared > /dev/null 2>&1
mkdir -p shared
docker-compose up --build -d
docker-compose exec synapse /home/synapse/scripts/init-shared.sh
