#!/usr/bin/bash

set -euo pipefail

pushd /home/snap/vigor
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
tar -xzvf /home/snap/files/cil.tar.gz -C /home/snap/.opam/4.06.0/lib

# Install graphviz for BDD visualization
sudo apt install graphviz -y

echo "source ~/.profile" >> /home/snap/.zshrc
