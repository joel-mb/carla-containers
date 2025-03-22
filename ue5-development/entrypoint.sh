#!/bin/bash
set -e

conda init bash >> /dev/null

echo "conda activate carla310" >> ~/.bashrc

exec "$@"
