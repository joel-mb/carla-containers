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

RUN apt-get update; \
  if [ "$UBUNTU_DISTRO" = "22.04" ]; then \
    packages='build-essential clang-10 lld-10 g++-7 cmake ninja-build libvulkan1 python python3 python3-dev python3-pip libpng-dev libtiff5-dev libjpeg-dev tzdata sed curl unzip autoconf libtool rsync libxml2-dev git git-lfs'; \
    apt-get install -y $packages; \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-10/bin/clang++ 180; \
    update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-10/bin/clang 180; \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 180; \
  elif [ "$UBUNTU_DISTRO" = "20.04" ]; then \
    packages='build-essential clang-10 lld-10 g++-7 cmake ninja-build libvulkan1 python python-dev python3-dev python3-pip libpng-dev libtiff5-dev libjpeg-dev tzdata sed curl unzip autoconf libtool rsync libxml2-dev git'; \
    apt-get install -y $packages; \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-10/bin/clang++ 180; \
    update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-10/bin/clang 180; \
  elif [ "$UBUNTU_DISTRO" = "18.04" ]; then \
    packages='build-essential clang-8 lld-8 g++-7 cmake ninja-build libvulkan1 python python-pip python-dev python3-dev python3-pip libpng-dev libtiff5-dev libjpeg-dev tzdata sed curl unzip autoconf libtool rsync libxml2-dev git'; \
    apt-get install -y $packages; \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-8/bin/clang++ 180; \
    update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-8/bin/clang 180; \
  fi; \
  rm -rf /var/lib/apt/lists/*

RUN packages='libsdl2-2.0' \
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

RUN bash build_scripts/build_cpython.sh --python-version 3.8.19
RUN bash build_scripts/build_cpython.sh --python-version 3.9.19
RUN bash build_scripts/build_cpython.sh --python-version 3.10.14

# Install python libraries at system level as the container is itented to run as
# the host user, which is unknown at this time.
USER root

RUN python3.8 -m pip install -r build_scripts/requirements3.8.txt
RUN python3.9 -m pip install -r build_scripts/requirements3.9.txt
RUN python3.10 -m pip install -r build_scripts/requirements3.10.txt

# Install auditwheel at system level as CARLA is using it for auditing the resulting wheels.
#RUN SYSTEM_PYTHON_VERSION=$(python3 -V | cut -d " " -f 2 | cut -d "." -f 1,2) \
    #&& python3 -m pip install -r build_scripts/requirements${SYSTEM_PYTHON_VERSION}.txt \
    #&& python3 -m pip install auditwheel==4.0.0
RUN python3 -m pip install auditwheel==4.0.0

USER carla
