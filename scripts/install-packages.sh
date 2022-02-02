#!/usr/bin/bash

set -euo pipefail

xargs sudo apt-get -y install </home/synapse/scripts/packages.txt
