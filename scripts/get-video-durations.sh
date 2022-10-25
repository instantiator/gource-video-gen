#!/bin/bash

set -e
set -o pipefail

usage() {
  cat << EOF
Usage:
    -r      --rename-videos     Rename videos to include their duration (in seconds)
    -h      --help              Prints this help message and exits
EOF
}

#defaults
RENAME=false

# parameters
while [ -n "$1" ]; do
  case $1 in
  -r | --rename-videos)
    COMBINE=true
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

# header
echo "duration_ms,duration_s,path"

for RESULT_PATH in results/*.mp4; do
    # skip files that look like they already have a duration
    DURATION_s=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 $RESULT_PATH)
    DURATION_s_0dp=$(printf "%.0f" $DURATION_s)
    DURATION_s_2dp=$(printf "%.2f" $DURATION_s)
    DURATION_ms=$(echo "1000*$DURATION_s" | bc)
    DURATION_ms_0dp=$(printf "%.0f" $DURATION_ms)

    REGEX_HAS_DURATION="results/.*[0-9]+\.mp4"
    if [[ $RESULT_PATH =~ $REGEX_HAS_DURATION ]]; then
        echo "$DURATION_ms_0dp,$DURATION_s_2dp,\"$RESULT_PATH\""
        continue
    fi

    # rename the file for its duration (backup the old one)
    if $RENAME; then
        RESULT_PATH_WITH_DURATION="$(dirname $RESULT_PATH)/$(basename $RESULT_PATH .mp4).$DURATION_s_0dp.mp4"
        if [ -e $RESULT_PATH_WITH_DURATION ]
        then
            rm -f $RESULT_PATH_WITH_DURATION.backup
            mv $RESULT_PATH_WITH_DURATION $RESULT_PATH_WITH_DURATION.backup
        fi
        mv $RESULT_PATH $RESULT_PATH_WITH_DURATION
        RESULT_PATH=$RESULT_PATH_WITH_DURATION
    fi

    echo "$DURATION_ms_0dp,$DURATION_s_2dp,\"$RESULT_PATH\""
done
