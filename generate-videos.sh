#!/bin/bash

set -e
set -o pipefail

usage() {
  cat << EOF
Usage:
    -c      --combine           Combines histories and captions for all repositories found
    -t      --title             Title for the combined video (use with --combine)
    -h      --help              Prints this help message and exits
EOF
}

# defaults
COMBINE=false
TITLE=Repositories

# parameters
while [ -n "$1" ]; do
  case $1 in
  -c | --combine)
    COMBINE=true
    ;;
  -t | --title)
    shift
    TITLE=$1
    ;;
  -h | --help)
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

echo Initiating video generation
echo Combine repositories: $COMBINE

docker run \
  -v $(pwd)/avatars:/src/avatars \
  -v $(pwd)/mp3s:/src/mp3s \
  -v $(pwd)/repos:/src/repos \
  -v $(pwd)/results:/src/results \
  -v $(pwd)/captions:/src/captions \
  -it \
  gource-video-gen --combine "$COMBINE" --title "$TITLE"
