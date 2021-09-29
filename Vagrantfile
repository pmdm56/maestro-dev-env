# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  config.vm.define "vigor"
  config.ssh.forward_agent = true

  config.vm.provider "virtualbox" do |vb|
    vb.name = "vigor"
    vb.gui = false
    vb.memory = "4096"
  end

  # Initial boilerplate config

  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    fallocate -l 8G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  SHELL

  # Setup Vigor environment

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    mkdir -p /home/vagrant/vigor
    cd /home/vagrant/vigor

    git clone https://github.com/fchamicapereira/vigor.git

    cd /home/vagrant/vigor
    chmod +x ./vigor/setup.sh
    ./vigor/setup.sh
  SHELL

  # Fix missing cil package

  config.vm.provision "file", source: "./cil.tar.gz", destination: "/home/vagrant/cil.tar.gz"
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    /home/vagrant/.opam/
    tar -xzvf /home/vagrant/cil.tar.gz -C /home/vagrant/.opam/4.06.0/lib
    rm /home/vagrant/cil.tar.gz
  SHELL

  # Setup P4 environment

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
end
