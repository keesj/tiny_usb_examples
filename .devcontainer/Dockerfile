# Do we want this?
FROM ubuntu:latest

# env variable only visible during build time
# https://stackoverflow.com/questions/8671308/non-interactive-method-for-dpkg-reconfigure-tzdata
ARG DEBIAN_FRONTEND=noninteractive

# https://dev.to/setevoy/docker-configure-tzdata-and-timezone-during-build-20bk
ENV TZ="Europe/Amsterdam"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


## account creation (Following) 
# https://code.visualstudio.com/docs/remote/containers-advanced#_adding-a-nonroot-user-to-your-dev-container
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID


# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# 
# Custom
#
RUN mkdir -p /scripts
COPY .devcontainer/build.sh /scripts
WORKDIR /scripts
RUN chmod +x build.sh
RUN cd /scripts/ ;  ./build.sh

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME


RUN sudo apt-get -q update && \
     sudo apt-get install -yq  build-essential iverilog git moreutils vim tmux graphviz python3-sphinx python3-pip python-is-python3 && \
     sudo rm -rf /var/lib/apt/lists/*

RUN python -mpip install sphinx-autobuild  sphinxcontrib-plantuml  sphinx-rtd-theme pillow
RUN python -mpip install git+https://github.com/tonybaloney/sphinxcontrib-confluencebuilder

