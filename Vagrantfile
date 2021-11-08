# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  config.vm.hostname = "synapse"
  config.vm.define "synapse"

  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.provider "virtualbox" do |vb|
    vb.name = "synapse"
    vb.gui = false
    vb.memory = "8192"
    vb.cpus = 6
  end

  config.vm.synced_folder "scripts/", "/home/vagrant/scripts/", owner: "vagrant", group: "vagrant"
  
  #################################################################
  # Copy required files to the VM first
  #################################################################

  config.vm.provision "file", source: "./bf-sde-9.7.0.tgz", destination: "/home/vagrant/bf-sde-9.7.0.tgz"
  config.vm.provision "file", source: "./bf-reference-bsp-9.7.0.tgz", destination: "/home/vagrant/bf-reference-bsp-9.7.0.tgz"
  config.vm.provision "file", source: "./ica-tools.tgz", destination: "/home/vagrant/ica-tools.tgz"
  config.vm.provision "file", source: "./cil.tar.gz", destination: "/home/vagrant/cil.tar.gz"

  #################################################################
  # Initial boilerplate config
  #################################################################

  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    # DNS fix
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

    # Creating swap
    fallocate -l 8G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  SHELL

  #################################################################
  # Setup Vigor environment
  #################################################################

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    mkdir -p /home/vagrant/vigor
    cd /home/vagrant/vigor

    git clone https://github.com/fchamicapereira/vigor.git

    cd /home/vagrant/vigor
    chmod +x ./vigor/setup.sh
    ./vigor/setup.sh

    # Install graphviz for BDD visualization
    sudo apt install graphviz xdot -y
  SHELL

  #################################################################
  # Fix missing cil package
  #################################################################

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    /home/vagrant/.opam/
    tar -xzvf /home/vagrant/cil.tar.gz -C /home/vagrant/.opam/4.06.0/lib
    rm /home/vagrant/cil.tar.gz
  SHELL

  #################################################################
  # Setup P4 environment
  #################################################################

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    sudo apt update
    sudo apt install python3 python3-pip -y

    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

    cd /home/vagrant/vigor
    git clone https://github.com/jafingerhut/p4-guide.git

    cd p4-guide/bin/
    ./install-p4dev-v4.sh

    echo "export BMV2=\"/home/vagrant/vigor/p4-guide/bin/behavioral-model/\"" >> /home/vagrant/.bashrc
  SHELL

  #################################################################
  # Setup Barefoot SDE
  #################################################################

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    sudo apt update
    sudo apt install python3 python3-pip cmake -y
    sudo apt install libcli-dev

    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

    tar xvfz bf-sde-9.7.0.tgz
    tar xvfz bf-reference-bsp-9.7.0.tgz
    tar xvfz ica-tools.tgz

    rm bf-sde-9.7.0.tgz
    rm bf-reference-bsp-9.7.0.tgz
    rm ica-tools.tgz

    cd bf-sde-9.7.0

    echo "Y" | ./p4studio/p4studio dependencies install

    ./p4studio/p4studio configure thrift-diags '^tofino2' bfrt \
                        switch p4rt thrift-switch thrift-driver \
                        sai '^tofino2m' '^tofino2h' bf-diags \
                        bfrt-generic-flags grpc tofino bsp \
                        --bsp-path=/home/vagrant/bf-reference-bsp-9.7.0.tgz

    ./p4studio/p4studio build

    echo "export SDE=/home/vagrant/bf-sde-9.7.0" >> ~/.profile
    echo "export SDE_INSTALL=/home/vagrant/bf-sde-9.7.0/install" >> ~/.profile
    
    ./p4studio/p4studio app activate >> ~/.bashrc
    echo "export PATH=$SDE_INSTALL/bin:\$PATH" >> ~/.bashrc
  SHELL
end
