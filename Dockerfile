FROM --platform=linux/amd64 ubuntu:focal

# https://stackoverflow.com/questions/51023312/docker-having-issues-installing-apt-utils
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Lisbon

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# The install scripts require sudo (no need to clean apt cache, the setup script will install stuff)
RUN apt-get update && apt-get install -y sudo

# Create a user with passwordless sudo
RUN adduser --disabled-password --gecos '' docker
RUN adduser docker sudo
RUN echo '%docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker
WORKDIR /home/docker/workspace

# Create workspace structure
RUN sudo chown -R docker:docker /home/docker/workspace

# Create the shared folder
RUN sudo mkdir /shared
RUN sudo chown -R docker:docker /shared

# Configure ssh directory
RUN mkdir /home/docker/.ssh
RUN chown -R docker:docker /home/docker/.ssh

# Install some nice to have applications
RUN sudo apt-get -y install \
    man \
    build-essential \
    wget \
    curl \
    git \
    vim \
    tzdata \
    tmux \
    iputils-ping \
    iproute2 \
    net-tools \
    tcpreplay \
    iperf \
    psmisc \
    htop \
    gdb \
    xdot \
    xdg-utils \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    zsh

RUN sudo dpkg-reconfigure --frontend noninteractive tzdata

# Installing terminal sugar
RUN curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

# Change default shell
RUN sudo chsh -s $(which zsh) 

# Setting up shared environment
COPY --chown=docker:docker ./setup-shared.sh /opt/setup-shared.sh
RUN chmod +x /opt/setup-shared.sh

RUN echo "/opt/setup-shared.sh" >> /home/docker/.profile
RUN echo "source ~/.profile" >> /home/docker/.zshrc
RUN echo "cd /home/docker/workspace" >> /home/docker/.zshrc

RUN git clone https://github.com/fchamicapereira/maestro.git
RUN chmod +x ./maestro/setup.sh
RUN cd maestro && ./setup.sh

CMD [ "/usr/bin/zsh" ]