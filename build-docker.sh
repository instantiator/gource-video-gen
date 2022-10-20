#!/bin/bash

set -e
set -o pipefail

docker build -t gource-video-gen --file ./Dockerfile-gource .
docker build -t video-grid-gen --file ./Dockerfile-grid .
