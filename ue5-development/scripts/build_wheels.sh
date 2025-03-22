#!/bin/bash

pushd "/workspace/carla" >> /dev/null

source /opt/conda/etc/profile.d/conda.sh

mkdir -p wheels

environments=("carla38" "carla39" "carla310" "carla311" "carla312")

for env in "${environments[@]}"; do
    echo "Activating conda environment: $env"
    conda activate "$env"

    rm -rf Build

    cmake --preset Linux-Release -DENABLE_ROS2=ON
    cmake --build Build/Linux-Release --target carla-python-api

    cp -r Build/Linux-Release/PythonAPI/dist/*.whl wheels
done

popd >> /dev/null
