#!/bin/bash

set -e
set -o pipefail

echo "Generating all videos..."

for REPO_PATH in repos/*; do
    [ -d "${REPO_PATH}" ] || continue # if not a directory, skip
    REPO_NAME="$(basename "${REPO_PATH}")"
    echo Found: $REPO_NAME
    AUDIO_PATH=mp3s/$REPO_NAME.mp3
    VIDEO_PATH=results/$REPO_NAME.mp4
    SILENT_VIDEO_PATH=results/$REPO_NAME.silent.mp4
    
    ./run-gource.sh \
      --repo $REPO_PATH \
      --output-video-path $SILENT_VIDEO_PATH

    if [ -e $AUDIO_PATH ]
    then
        ./apply-audio.sh \
          --input-video $SILENT_VIDEO_PATH \
          --input-audio $AUDIO_PATH \
          --output-video $VIDEO_PATH
    else
        mv $SILENT_VIDEO_PATH $VIDEO_PATH
    fi

done
