ARG UBUNTU_DISTRO="22.04"

FROM ubuntu:${UBUNTU_DISTRO}

ARG HOST_UID="1000"
ARG HOST_GID="1000"

# Disable interactive prompts during package installation.
ENV DEBIAN_FRONTEND=noninteractive

# Install sudo if needed for privileged commands.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a dedicated non-root user and group to limit root access.
# Add the user to the sudoers group and configure it password-less.
RUN groupadd --gid ${HOST_GID} carla \
    && useradd -m --uid ${HOST_UID} -g carla carla \
    && passwd -d carla \
    && usermod -a -G sudo carla

USER carla

ENV HOME="/home/carla"
WORKDIR /workspace

COPY --chown=carla:carla envs ${HOME}/envs

# ---------------------------
# Install CARLA prerequisites
# ---------------------------
USER root

# Setup proper locale.
RUN packages='locales' \
    && apt-get update \
    && apt-get install --reinstall -y $packages \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US
ENV LC_ALL=en_US.UTF-8

# Install CARLA UE5 prerequisites.
# TODO: Insert the documentation URL when it becomes available.
# https://github.com/carla-simulator/carla/blob/ue5-dev/CarlaSetup.sh
RUN packages='build-essential g++-12 gcc-12 make ninja-build libvulkan1 python3 python3-dev python3-pip libpng-dev libtiff5-dev libjpeg-dev tzdata sed curl libtool rsync libxml2-dev git git-lfs' \
    && apt-get update \
    && apt-get install -y $packages --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
RUN curl -L -O https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.tar.gz \
    && mkdir -p /opt \
    && tar -xzf cmake-3.28.3-linux-x86_64.tar.gz -C /opt \
    && rm -rf cmake-3.28.3-linux-x86_64.tar.gz
ENV PATH=/opt/cmake-3.28.3-linux-x86_64/bin:$PATH

# -------------
# Install conda
# -------------
USER root

RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && chmod +x Miniconda3-latest-Linux-x86_64.sh \
    && ./Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH=/opt/conda/bin:$PATH

RUN /opt/conda/bin/conda env create -f ${HOME}/envs/carla38.yml
RUN /opt/conda/bin/conda env create -f ${HOME}/envs/carla39.yml
RUN /opt/conda/bin/conda env create -f ${HOME}/envs/carla310.yml
RUN /opt/conda/bin/conda env create -f ${HOME}/envs/carla311.yml
RUN /opt/conda/bin/conda env create -f ${HOME}/envs/carla312.yml

# -------------------------
# Install UE5 prerequisites
# -------------------------
USER root

# TODO: Investigate why we need to install a complete xserver on the container
# to share the display. If not installed, vulkan cannot find a compatible
# vulkan device that supports surface presentation.
RUN packages='xserver-xorg' \
    && apt-get update \
    && apt-get install -y $packages --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install the `xdg-user-dir` and `xdg-utils` tool so the Unreal Engine can
# use it to locate the user's Documents directory.
RUN packages='xdg-user-dirs xdg-utils' \
    && apt-get update \
    && apt-get install -y $packages --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Starting in Unreal Engine 5.0, we need these installed before creating an
# Installed Build to prevent cooking failures related to loading the Quixel
# Bridge plugin
# https://github.com/adamrehn/ue4-docker/blob/master/src/ue4docker/dockerfiles/ue4-build-prerequisites/linux/Dockerfile#L47
RUN packages='libasound2 libatk1.0-0 libatk-bridge2.0-0 libcairo2 libfontconfig1 libfreetype6 libgbm1 libglu1 libnss3 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libsm6 libxcomposite1 libxcursor1 libxdamage1 libxi6 libxkbcommon-x11-0 libxrandr2 libxrender1 libxss1 libxtst6 libxv1 x11-xkb-utils xauth xfonts-base xkb-data' \
    && apt-get update \
    && apt-get install -y $packages --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

USER carla

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
