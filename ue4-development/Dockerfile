ARG UBUNTU_DISTRO="20.04"

FROM ubuntu:${UBUNTU_DISTRO}

ARG UBUNTU_DISTRO

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

COPY --chown=carla:carla build_scripts build_scripts

# ---------------------------
# Install CARLA prerequisites
# ---------------------------
# https://carla.readthedocs.io/en/latest/build_linux/#system-requirements
USER root

# Core build tools
# - build-essential cmake ninja-build
#
# Vulkan support:
# - libvulkan1: vulkan runtime needed by Unreal Engine for rendering
#
# Python environment:
# - python3, python3-dev, python3-pip: python runtime, development headers, and package manager installed at system level
# - python-is-python3: symlink `python` to `python3` for compatibility (only Ubuntu20.04 and Ubuntu22.04)
#
# Patchelf dependency:
# - autoconf: required for building patchelf from source
#
# Utility tools used in scripts:
# - wget, curl, rsync, unzip, git: essential CLI tools used in CARLA's build scripts.
#
# Image libraries:
# - libpng-dev, libtiff5-dev, libjpeg-dev: CARLA's Python API links to these system libraries
RUN packages='build-essential ninja-build libvulkan1 python3 python3-dev python3-pip autoconf wget curl rsync unzip git libpng-dev libtiff5-dev libjpeg-dev' && \
  apt-get update && \
  apt-get install -y $packages && \
  if [ "$UBUNTU_DISTRO" = "22.04" ]; then \
    packages="python-is-python3" && \
    apt-get install -y $packages; \
  elif [ "$UBUNTU_DISTRO" = "20.04" ]; then \
      packages="python-is-python3" && \
    apt-get install -y $packages; \
  elif [ "$UBUNTU_DISTRO" = "18.04" ]; then \
    packages="python" && \
    apt-get install -y $packages; \
  fi && \
  rm -rf /var/lib/apt/lists/*

# Minimum required version is 3.14.2.
# Install a newer version manually, as older Ubuntu versions include outdated CMake versions from the upstream repository
RUN curl -L -O https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.tar.gz \
    && mkdir -p /opt \
    && tar -xzf cmake-3.28.3-linux-x86_64.tar.gz -C /opt \
    && rm -rf cmake-3.28.3-linux-x86_64.tar.gz
ENV PATH=/opt/cmake-3.28.3-linux-x86_64/bin:$PATH

# SDL2 libraries:
# Required for Unreal Engine to interact with the display.
# - libsdl2-dev: development headers
# - libsdl2-2.0: runtime library
RUN packages='libsdl2-dev libsdl2-2.0' \
    && apt-get update \
    && apt-get install -y $packages \
    && rm -rf /var/lib/apt/lists/*

# ---------------
# Install CPython
# ---------------
# https://devguide.python.org/getting-started/setup-building/#install-dependencies
USER root

RUN packages='build-essential gdb lcov pkg-config libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev lzma lzma-dev tk-dev uuid-dev zlib1g-dev libmpdec-dev wget'; \
    apt-get update; \
    apt-get install -y $packages; \
    rm -rf /var/lib/apt/lists/*

RUN bash build_scripts/build_cpython.sh --python-version 3.7.17
RUN bash build_scripts/build_cpython.sh --python-version 3.8.19
RUN bash build_scripts/build_cpython.sh --python-version 3.9.19
RUN bash build_scripts/build_cpython.sh --python-version 3.10.14

# Install python libraries at system level
USER root

RUN python3.7 -m pip install -r build_scripts/requirements3.7.txt
RUN python3.8 -m pip install -r build_scripts/requirements3.8.txt
RUN python3.9 -m pip install -r build_scripts/requirements3.9.txt
RUN python3.10 -m pip install -r build_scripts/requirements3.10.txt

# Install requirements at system level as CARLA is using it for auditing the resulting wheels.
RUN SYSTEM_PYTHON_VERSION=$(python3 -V | cut -d " " -f 2 | cut -d "." -f 1,2) \
    && python3 -m pip install -r build_scripts/requirements${SYSTEM_PYTHON_VERSION}.txt

USER carla
