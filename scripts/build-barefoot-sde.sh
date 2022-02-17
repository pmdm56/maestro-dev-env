#!/usr/bin/bash

set -euo pipefail

sudo apt update
sudo apt install python3 python3-pip cmake -y
sudo apt install libcli-dev -y

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

tar xvfz /home/snap/files/patches.tgz -C /home/snap/files
tar xvfz /home/snap/files/bf-sde-9.7.0.tgz -C /home/snap
tar xvfz /home/snap/files/ica-tools.tgz -C /home/snap

cd /home/snap

patch -s -p0 < /home/snap/files/bf-sde-deps.patch

pushd bf-sde-9.7.0
    echo "Y" | ./p4studio/p4studio dependencies install

    ./p4studio/p4studio configure thrift-diags '^tofino2' bfrt \
                        switch p4rt thrift-switch thrift-driver \
                        sai '^tofino2m' '^tofino2h' bf-diags \
                        bfrt-generic-flags grpc tofino bsp \
                        --bsp-path=/home/snap/files/bf-reference-bsp-9.7.0.tgz

    ./p4studio/p4studio build
popd

patch -s -p0 < /home/snap/files/bf-sde-pkgsrc.patch

echo "export SDE=/home/snap/bf-sde-9.7.0" >> ~/.profile
echo "export SDE_INSTALL=/home/snap/bf-sde-9.7.0/install" >> ~/.profile
echo "export PATH=/home/snap/bf-sde-9.7.0/install/bin:\$PATH" >> ~/.zshrc