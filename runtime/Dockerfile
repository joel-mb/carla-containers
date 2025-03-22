ARG UBUNTU_DISTRO="20.04"

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

# Starting with Ubuntu 23.04, official Docker images include a default `ubuntu` user with UID 1000.
# This can cause conflicts when remapping the container's UID/GID to match the host user, which often also uses UID 1000.
# To prevent these conflicts, we remove the `ubuntu` user from the container.
RUN id -u ${HOST_UID} &>/dev/null \
    && userdel -r $(getent passwd ${HOST_UID} | cut -d: -f1) \
    || echo ""

# Create a dedicated non-root user and group to limit root access.
# Add the user to the sudoers group and configure it password-less.
RUN groupadd --gid ${HOST_GID} carla \
    && useradd -m --uid ${HOST_UID} -g carla carla \
    && passwd -d carla \
    && usermod -a -G sudo carla

ENV HOME="/home/carla"
WORKDIR /workspace

RUN packages='libsdl2-2.0 xserver-xorg libvulkan1 libomp5' \
    && apt-get update \
    && apt-get install -y $packages \
    && rm -rf /var/lib/apt/lists/*

# Install the `xdg-user-dir` tool so the Unreal Engine can use it to locate the user's Documents directory
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && apt-get install -y --no-install-recommends xdg-user-dirs && rm -rf /var/lib/apt/lists/*

ENV OMP_PROC_BIND="FALSE"
ENV OMP_NUM_THREADS="48"
ENV SDL_VIDEODRIVER="x11"
ENV NVIDIA_DRIVER_CAPABILITIES="all"

USER carla
WORKDIR /home/carla
