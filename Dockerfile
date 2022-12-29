####################################################################
#                                                                  #
#                              samwise                                #
#                                                                  #
####################################################################

FROM ubuntu:focal

# https://stackoverflow.com/questions/51023312/docker-having-issues-installing-apt-utils
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Lisbon

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# The install scripts require sudo (no need to clean apt cache, the setup script will install stuff)
RUN apt-get update && apt-get install -y sudo

# Create (-m == with a homedir) and use a user with passwordless sudo
RUN useradd -m samwise \
    && echo "samwise:samwise" | chpasswd \
    && adduser samwise sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Change root password
RUN echo 'root:samwise' | chpasswd

USER samwise
WORKDIR /home/samwise/workspace

# Create workspace structure
RUN sudo chown -R samwise:samwise /home/samwise/workspace

# Create the shared folder
RUN sudo mkdir /shared
RUN sudo chown -R samwise:samwise /shared

# Configure ssh directory
RUN mkdir /home/samwise/.ssh
RUN chown -R samwise:samwise /home/samwise/.ssh

# Install some nice to have applications
RUN sudo apt-get update
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
COPY --chown=samwise:samwise ./setup-shared.sh /opt/setup-shared.sh
RUN chmod +x /opt/setup-shared.sh

RUN echo "/opt/setup-shared.sh" >> /home/samwise/.profile
RUN echo "source ~/.profile" >> /home/samwise/.zshrc
RUN echo "cd /home/samwise/workspace" >> /home/samwise/.zshrc

RUN git clone https://github.com/fchamicapereira/maestro.git

RUN chmod +x ./maestro/setup.sh
# RUN cd maestro && ./setup.sh