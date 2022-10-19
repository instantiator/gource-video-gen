#!/bin/bash

set -e
set -o pipefail

# header
echo "duration,path"

for RESULT_PATH in results/*.mp4; do
    # skip files that look like they already have a duration
    DURATION_s=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 $RESULT_PATH)
    DURATION_ms=$(echo "1000*$DURATION_s" | bc)
    DURATION_ms_0dp=$(printf "%.0f" $DURATION_ms)

    REGEX_HAS_DURATION="results/.*[0-9]+\.mp4"
    if [[ $RESULT_PATH =~ $REGEX_HAS_DURATION ]]; then
        echo "$DURATION_ms_0dp,\"$RESULT_PATH\""
        continue
    fi

    # rename the file for its duration
    DURATION_s_0dp=$(printf "%.0f" $DURATION_s)
    RESULT_PATH_WITH_DURATION="$(dirname $RESULT_PATH)/$(basename $RESULT_PATH .mp4).$DURATION_s_0dp.mp4"
    mv $RESULT_PATH $RESULT_PATH_WITH_DURATION

    echo "$DURATION_ms_0dp,\"$RESULT_PATH_WITH_DURATION\""
done
