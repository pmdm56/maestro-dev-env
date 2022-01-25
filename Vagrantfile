# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  config.vm.hostname = "synapse"
  config.vm.define "synapse"
  
  config.ssh.keep_alive = true
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.provider "virtualbox" do |vb|
    vb.name = "synapse"
    vb.gui = false
    vb.memory = "8192"
    vb.cpus = 6
  end

  config.vm.provider "vmware_desktop" do |vb|
    vb.gui = false
    vb.memory = "4096"
    vb.cpus = 2
  end

  config.vm.synced_folder "scripts/", "/home/vagrant/scripts/", owner: "vagrant", group: "vagrant"
  config.vm.synced_folder "workspace/", "/home/vagrant/workspace", create: true, owner: "vagrant", group: "vagrant"
  
  #################################################################
  # Copy required files to the VM first
  #################################################################

  config.vm.provision "file", source: "./patches.tgz", destination: "/home/vagrant/files/patches.tgz"
  config.vm.provision "file", source: "./bf-sde-9.7.0.tgz", destination: "/home/vagrant/files/bf-sde-9.7.0.tgz"
  config.vm.provision "file", source: "./bf-reference-bsp-9.7.0.tgz", destination: "/home/vagrant/files/bf-reference-bsp-9.7.0.tgz"
  config.vm.provision "file", source: "./ica-tools.tgz", destination: "/home/vagrant/files/ica-tools.tgz"
  config.vm.provision "file", source: "./cil.tar.gz", destination: "/home/vagrant/files/cil.tar.gz"

  #################################################################
  # Initial boilerplate config
  #################################################################

  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    # DNS fix
    sudo sed -i 's/^.*DNS=.*$/DNS=8.8.8.8 8.8.4.4/g' /etc/systemd/resolved.conf
    sudo rm /etc/resolv.conf
    sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
    sudo service systemd-resolved restart
    
    # Creating swap
    fallocate -l 8G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  SHELL
  
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    # Installing terminal sugar
    sudo apt install zsh -y
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sed -i 's/^ZSH_THEME=\".*$/ZSH_THEME=\"kafeitu\"/g' /home/vagrant/.zshrc
    git clone https://github.com/zsh-users/zsh-autosuggestions /home/vagrant/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    sed -i 's/^plugins=\(.*\)$/plugins=\(git zsh-autosuggestions\)/g' /home/vagrant/.zshrc
    sudo chsh -s /bin/zsh vagrant

    echo -e "emulate sh\n. ~/.profile\nemulate zsh" > /home/vagrant/.zprofile
    
    echo -e "alias ws=\"cd ~/workspace\"" >> /home/vagrant/.zshrc
    echo -e "alias vigor=\"cd ~/vigor\"" >> /home/vagrant/.zshrc
  SHELL

  #################################################################
  # Setup Vigor environment
  #################################################################

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    pushd /home/vagrant/workspace
      git clone https://github.com/fchamicapereira/vigor.git
    popd

    mkdir -p /home/vagrant/vigor

    pushd /home/vagrant/vigor
      ln -s /home/vagrant/workspace/vigor vigor
      chmod +x ./vigor/setup.sh
      ./vigor/setup.sh .
    popd

    pushd /home/vagrant/workspace
      git clone https://github.com/fchamicapereira/vigor-klee.git klee
      cd klee
      ./build.sh
    popd

    pushd /home/vagrant/vigor
      rm -rf klee
      ln -s /home/vagrant/workspace/klee klee
    popd

    # Install graphviz for BDD visualization
    sudo apt install graphviz xdot -y
  SHELL

  #################################################################
  # Fix missing cil package
  #################################################################

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    /home/vagrant/.opam/
    tar -xzvf /home/vagrant/files/cil.tar.gz -C /home/vagrant/.opam/4.06.0/lib
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

    echo "export BMV2=\"/home/vagrant/vigor/p4-guide/bin/behavioral-model/\"" >> /home/vagrant/.zshrc
  SHELL

  #################################################################
  # Setup Barefoot SDE
  #################################################################

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    sudo apt update
    sudo apt install python3 python3-pip cmake -y
    sudo apt install libcli-dev

    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

    tar xvfz /home/vagrant/files/patches.tgz -C /home/vagrant
    tar xvfz /home/vagrant/files/bf-sde-9.7.0.tgz -C /home/vagrant
    tar xvfz /home/vagrant/files/bf-reference-bsp-9.7.0.tgz -C /home/vagrant
    tar xvfz /home/vagrant/files/ica-tools.tgz -C /home/vagrant

    cd bf-sde-9.7.0

    echo "Y" | ./p4studio/p4studio dependencies install

    ./p4studio/p4studio configure thrift-diags '^tofino2' bfrt \
                        switch p4rt thrift-switch thrift-driver \
                        sai '^tofino2m' '^tofino2h' bf-diags \
                        bfrt-generic-flags grpc tofino bsp \
                        --bsp-path=/home/vagrant/files/bf-reference-bsp-9.7.0.tgz

    ./p4studio/p4studio build

    patch -s -p0 < bf-sde-pkgsrc.patch

    echo "export SDE=/home/vagrant/bf-sde-9.7.0" >> ~/.profile
    echo "export SDE_INSTALL=/home/vagrant/bf-sde-9.7.0/install" >> ~/.profile
    
    echo "export PATH=$SDE_INSTALL/bin:\$PATH" >> ~/.zshrc
  SHELL
end
