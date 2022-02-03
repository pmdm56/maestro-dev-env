#!/usr/bin/bash

set -euo pipefail

# We need to be root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

mkdir -p /mnt/hugepages2M
mount -t hugetlbfs -o pagesize=2M none /mnt/hugepages2M

# ~64 MB of hugepages
su -c "echo 32 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages"

echo "*********** /proc/meminfo content *********** "
cat /proc/meminfo | grep Huge
