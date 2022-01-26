#!/usr/bin/bash

set -euo pipefail

pushd /home/synapse/vigor
    git clone https://github.com/fchamicapereira/vigor.git
    
    chmod +x ./vigor/setup.sh
    ./vigor/setup.sh .
    
    rm -rf klee
    git clone https://github.com/fchamicapereira/vigor-klee.git klee
    
    pushd klee
        ./build.sh
    popd
popd

# Fix missing cil package
tar -xzvf /home/synapse/files/cil.tar.gz -C /home/synapse/.opam/4.06.0/lib

# Install graphviz for BDD visualization
sudo apt install graphviz xdot -y

RUN echo "source ~/.profile" >> /home/synapse/.zshrc
