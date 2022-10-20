#!/bin/bash

set -e
set -o pipefail

# recalculate all video durations
./get-video-durations.sh > results/durations.csv
cat results/durations.csv

# find the longest video
LONGEST_ms=$(q -H -d , "select MAX(duration) FROM results/durations.csv")
echo "Longest video: $LONGEST_ms"

# compose the base ffmpeg command
# TODO

# establish the offset for each video and append to the ffmpeg command
for VIDEO_PATH in results/*.mp4; do
    THIS_name=$(basename $VIDEO_PATH)
    THIS_ms=$(q -H -d , "select duration FROM results/durations.csv WHERE path='$VIDEO_PATH'")
    THIS_OFFSET_ms=$(echo "$LONGEST_ms - $THIS_ms" | bc)
    
    echo "$THIS_name duration: $THIS_ms offset: $THIS_OFFSET_ms"

    # TODO
done
