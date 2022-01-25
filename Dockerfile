FROM ubuntu:focal

# https://stackoverflow.com/questions/51023312/docker-having-issues-installing-apt-utils
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Lisbon

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# The install scripts require sudo (no need to clean apt cache, the setup script will install stuff)
RUN apt-get update && apt-get install -y sudo

# Create (-m == with a homedir) and use a user with passwordless sudo
RUN useradd -m synapse \
    && echo "synapse:synapse" | chpasswd \
    && adduser synapse sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER synapse
WORKDIR /home/synapse

# Create workspace structure
RUN mkdir /home/synapse/vigor
RUN mkdir /home/synapse/scripts
RUN mkdir /home/synapse/files
RUN mkdir /home/synapse/shared

# Configure ssh directory
RUN mkdir /home/synapse/.ssh
RUN chown -R synapse:synapse /home/synapse/.ssh

# Copy scripts into the workspace
COPY --chown=synapse:synapse ./scripts /home/synapse/scripts

# Copy other required files
COPY --chown=synapse:synapse ./patches.tgz /home/synapse/files/patches.tgz
COPY --chown=synapse:synapse ./bf-sde-9.7.0.tgz /home/synapse/files/bf-sde-9.7.0.tgz
COPY --chown=synapse:synapse ./bf-reference-bsp-9.7.0.tgz /home/synapse/files/bf-reference-bsp-9.7.0.tgz
COPY --chown=synapse:synapse ./ica-tools.tgz /home/synapse/files/ica-tools.tgz
COPY --chown=synapse:synapse ./cil.tar.gz /home/synapse/files/cil.tar.gz

# Install some nice to have applications
RUN sudo apt-get install -y man
RUN sudo apt-get install -y build-essential wget vim tzdata
RUN sudo dpkg-reconfigure --frontend noninteractive tzdata

# Installing terminal sugar
# Uses "Spaceship" theme with some customization. Uses some bundled plugins and installs some more from github
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

RUN echo "alias vigor=\"cd ~/vigor\"" >> /home/synapse/.zshrc

# Execute the setup scripts
RUN chmod +x /home/synapse/scripts/build-vigor.sh
RUN chmod +x /home/synapse/scripts/build-p4.sh
RUN chmod +x /home/synapse/scripts/build-barefoot-sde.sh

RUN /home/synapse/scripts/build-vigor.sh
RUN /home/synapse/scripts/build-p4.sh
RUN /home/synapse/scripts/build-barefoot-sde.sh
