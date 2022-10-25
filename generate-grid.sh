#!/bin/bash

set -e
set -o pipefail

usage() {
  cat << EOF
Creates a grid of videos from the contents of the results directory.

Options:
    -w <n>  --width <n>         Number of videos wide
    -h <n>  --height <n>        Number of videos tall
            --help              Prints this help message and exits
EOF
}

# parameters
while [ -n "$1" ]; do
  case $1 in
  -w | --width)
    shift
    WIDTH=$1
    ;;
  -h | --height)
    shift
    HEIGHT=$1
    ;;
  --help)
    usage
    exit 0
    ;;
  *)
    echo -e "Unknown option $1...\n"
    usage
    exit 1
    ;;
  esac
  shift
done

./init-directories.sh
./build-docker.sh

docker run \
  -v $(pwd)/mp3s:/src/mp3s \
  -v $(pwd)/results:/src/results \
  -it \
  video-grid-gen --width $WIDTH --height $HEIGHT
