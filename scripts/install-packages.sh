#!/usr/bin/bash

set -euo pipefail

xargs sudo apt-get -y install </opt/files/packages.txt
