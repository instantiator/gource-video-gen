#!/bin/bash

set -e
set -o pipefail

./build-docker.sh

docker run \
  -v $(pwd)/mp3s:/src/mp3s \
  -v $(pwd)/results:/src/results \
  -it \
  video-grid-gen
