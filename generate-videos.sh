#!/bin/bash

./init-directories.sh
./build-docker.sh

docker run \
  -v $(pwd)/avatars:/src/avatars \
  -v $(pwd)/mp3s:/src/mp3s \
  -v $(pwd)/repos:/src/repos \
  -v $(pwd)/results:/src/results \
  -v $(pwd)/captions:/src/captions \
  -it \
  gource-video-gen
