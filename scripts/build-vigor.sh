#!/usr/bin/bash

set -euo pipefail

pushd /home/synapse/shared
    git clone https://github.com/fchamicapereira/vigor.git
    git clone https://github.com/fchamicapereira/vigor-klee.git klee
popd

pushd /home/synapse/vigor
    ln -s /home/synapse/shared/vigor vigor
    chmod +x ./vigor/setup.sh
    ./vigor/setup.sh .
    
    rm -rf klee
    ln -s /home/synapse/shared/klee klee
    pushd klee
        ./build.sh
    popd
popd

# Fix missing cil package
tar -xzvf /home/synapse/files/cil.tar.gz -C /home/synapse/.opam/4.06.0/lib

# Install graphviz for BDD visualization
sudo apt install graphviz xdot -y
