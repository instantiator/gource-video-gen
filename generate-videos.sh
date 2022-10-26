#!/bin/bash

set -e
set -o pipefail

usage() {
  cat << EOF
Options:
    -c         --combine              Combines histories and captions for all repositories found
    -a         --anonymise            Generates anonymous video (no names, no directories, no filenames)
    -d         --no-date              Hide the time/date
    -s         --no-skip              Don't skip quiet periods
    -dl <secs> --day-length <secs>    Seconds per day (default = 0.66)
    -t         --title                Title for the combined video (use with --combine)
    -h         --help                 Prints this help message and exits
EOF
}

# defaults
COMBINE=false
ANON=false
TITLE=Repositories
NODATE=false
NOSKIP=false
SECS_PER_DAY=0.66

# parameters
while [ -n "$1" ]; do
  case $1 in
  -c | --combine)
    COMBINE=true
    ;;
  -a | --anonymise)
    ANON=true
    ;;
  -d | --no-date)
    NODATE=true
    ;;
  -t | --title)
    shift
    TITLE=$1
    ;;
  -dl | --day-length)
    shift
    SECS_PER_DAY=$1
    ;;
  -s | --no-skip)
    NOSKIP=true
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
echo Anonymise: $ANON
echo "Day length: $SECS_PER_DAY (secs)"

docker run \
  -v $(pwd)/avatars:/src/avatars \
  -v $(pwd)/mp3s:/src/mp3s \
  -v $(pwd)/repos:/src/repos \
  -v $(pwd)/results:/src/results \
  -v $(pwd)/captions:/src/captions \
  -it \
  gource-video-gen --combine "$COMBINE" --anonymise "$ANON" --title "$TITLE" --no-date "$NODATE" --no-skip "$NOSKIP" --day-length "$SECS_PER_DAY"
