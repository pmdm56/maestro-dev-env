#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
HUGEPAGES="$SCRIPT_DIR/../hugepages2M"

# Check if we are running on linux
host_os=$(uname -s)

if [ "$host_os" != "Linux" ]; then
  echo ""
  echo "************************** WARNING *************************** "
  echo "* This script only knows how to allocate hugepages on Linux. * "
  echo "* If you are currently running Windows or MacOS, try         * "
  echo "* allocating hugepages inside the container.                 * "
  echo "************************************************************** "
  echo ""

  exit 0
fi

# We need to be root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

mkdir -p $HUGEPAGES
mount -t hugetlbfs -o pagesize=2M none $HUGEPAGES

# ~64 MB of hugepages
su -c "echo 32 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages"

echo "*********** /proc/meminfo content *********** "
cat /proc/meminfo | grep Huge
