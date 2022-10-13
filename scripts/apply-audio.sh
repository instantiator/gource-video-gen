#!/bin/bash

set -e
set -o pipefail

usage() {
  cat << EOF
Usage:
    -iv     --input-video       Path to the original video file
    -ia     --input-audio       Path to the audio file to mix in
    -ov     --output-video      Path to the output video file
    -h      --help              Prints this help message and exits
EOF
}

while [ -n "$1" ]; do
  case $1 in
  -iv | --input-video)
    shift
    IN_VIDEO_PATH=$1
    ;;
  -ia | --input-audio)
    shift
    IN_AUDIO_PATH=$1
    ;;
  -ov | --output-video)
    shift
    OUT_VIDEO_PATH=$1
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

echo Mixing audio with ffmpeg...
echo Input video: $IN_VIDEO_PATH
echo Input audio: $IN_AUDIO_PATH
echo Output video: $OUT_VIDEO_PATH

# backup previous video
if [ -e $OUT_VIDEO_PATH ]
then
    rm -f $OUT_VIDEO_PATH.backup
    mv $OUT_VIDEO_PATH $OUT_VIDEO_PATH.backup
fi

ffmpeg \
  -i $IN_VIDEO_PATH \
  -i $IN_AUDIO_PATH \
  -c:v copy \
  -c:a aac -strict experimental \
  $OUT_VIDEO_PATH

# some other ffmpeg options for reference...

# -filter:a "volume=0.6" 
