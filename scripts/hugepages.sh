#!/bin/bash

set -euo pipefail

HUGEPAGES="/mnt/hugepages2M"

# We need to be root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

mkdir -p $HUGEPAGES
mount -t hugetlbfs -o pagesize=2M none $HUGEPAGES

# ~64 MB of hugepages
su -c "echo 32 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"

echo "*********** /proc/meminfo content *********** "
grep "Huge" /proc/meminfo
