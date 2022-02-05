####################################################################
#                                                                  #
#                              SNAP                                #
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
RUN useradd -m snap \
    && echo "snap:snap" | chpasswd \
    && adduser snap sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Change root password
RUN echo 'root:snap' | chpasswd

USER snap
WORKDIR /home/snap

# Create workspace structure
RUN mkdir /home/snap/vigor
RUN mkdir /home/snap/scripts
RUN mkdir /home/snap/files
RUN mkdir /home/snap/.shared

# Configure ssh directory
RUN mkdir /home/snap/.ssh
RUN chown -R snap:snap /home/snap/.ssh

# Copy scripts and files into the workspace
COPY --chown=snap:snap ./scripts /home/snap/scripts
COPY --chown=snap:snap ./resources /home/snap/files

# Make the scripts executable
RUN chmod +x /home/snap/scripts/*.sh

# Install some nice to have applications
RUN /home/snap/scripts/install-packages.sh
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

# Change default shell
RUN sudo chsh -s $(which zsh) 
RUN echo "alias vigor=\"cd ~/vigor\"" >> /home/snap/.zshrc

# Use the provided tmux configuration
RUN cp /home/snap/files/.tmux.conf /home/snap

# Setting up shared environment
RUN echo "/home/snap/scripts/setup-shared.sh" >> /home/snap/.profile