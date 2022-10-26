#!/bin/bash

set -e
set -o pipefail

usage() {
  cat << EOF
Usage:
    -w <n>  --width <n>         Number of videos wide
    -h <n>  --height <n>        Number of videos tall
            --help              Prints this help message and exits
EOF
}

# some defaults
SCRIPT_PATH=$(dirname "$0")

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

echo "Creating video grid..."
echo Width: $WIDTH
echo Height: $HEIGHT

# recalculate all video durations
$SCRIPT_PATH/get-video-durations.sh > results/durations.csv
cat results/durations.csv

# find the longest video
LONGEST_ms=$(q -H -d , "select MAX(duration_ms) FROM results/durations.csv")
echo "Longest video: $LONGEST_ms"

# compose the base ffmpeg command
# TODO

# establish the offset for each video and append to the ffmpeg command
CMD="ffmpeg"
ALL_DELAY_FILTERS=""
V=0
for VIDEO_PATH in results/*.mp4; do
    THIS_name=$(basename $VIDEO_PATH)
    THIS_ms=$(q -H -d , "select duration_ms FROM results/durations.csv WHERE path='$VIDEO_PATH'")
    THIS_OFFSET_ms=$(echo "$LONGEST_ms - $THIS_ms" | bc)
    THIS_OFFSET_s=$(echo "$THIS_OFFSET_ms / 1000.0" | bc)
    
    echo "Video $V: $THIS_name Duration: $THIS_ms Offset: $THIS_OFFSET_s secs"

    #THIS_FILTER="[$V:v]setpts=PTS-STARTPTS+$THIS_OFFSET_s/TB[delayed$V]"
    THIS_FILTER="[$V:v]tpad=start_mode=clone:start_duration=$THIS_OFFSET_s[d$V];"
    echo $THIS_FILTER

    ALL_DELAY_FILTERS="${ALL_DELAY_FILTERS}${THIS_FILTER}" # collect all filters

    CMD="${CMD} -i ${VIDEO_PATH}"
    V=$((V+1))
done

# assemble videos
ALL_ROW_STACKS=""
THIS_V_STACK=""
VC=0
for ((ROW=0;ROW<HEIGHT;ROW++));
do
    THIS_ROW_STACK=""
    for ((COL=0;COL<WIDTH;COL++));
    do
        THIS_ROW_STACK="$THIS_ROW_STACK[d$VC]"
        VC=$((VC+1))
    done # COL
    THIS_ROW_STACK="${THIS_ROW_STACK}hstack=inputs=$WIDTH[r$ROW];"
    ALL_ROW_STACKS="$ALL_ROW_STACKS$THIS_ROW_STACK"
    THIS_V_STACK="${THIS_V_STACK}[r$ROW]"
done # ROW
THIS_V_STACK="${THIS_V_STACK}vstack=inputs=$HEIGHT[v]"

ALL_FILTERS="${ALL_DELAY_FILTERS}${ALL_ROW_STACKS}${THIS_V_STACK}"

echo
echo $ALL_FILTERS

CMD="${CMD} -filter_complex \"${ALL_FILTERS}\" -map \"[v]\" grid.mp4"

echo
echo $CMD

# Some sample ffmpeg calls
# See also: https://ottverse.com/stack-videos-horizontally-vertically-grid-with-ffmpeg/


# delay (clone first frame)
# ffmpeg -i background.mp4 -i front.mp4 -filter_complex "[0]tpad=start_duration=2:start_mode=clone[bg];[bg][1]overlay" output.mp4

# delay (show solid colour)
# ffmpeg -i background.mp4 -i front.mp4 -filter_complex "[0]tpad=start_duration=2:start_mode=add:color=black[bg];[bg][1]overlay" output.mp4

# 3x2
# ffmpeg \
#     -i input0.mp4 -i input1.mp4 \
#     -i input2.mp4 -i input3.mp4 \
#     -i input4.mp4 -i input5.mp4 \
#     -filter_complex \
#     "[0:v][1:v][2:v]hstack=inputs=3[top];\
#     [3:v][4:v][5:v]hstack=inputs=3[bottom];\
#     [top][bottom]vstack=inputs=2[v]" \
#     -map "[v]" \
#     finalOutput.mp4

# 2x2
# ffmpeg \
#     -i input0.mp4 -i input1.mp4 -i input2.mp4 -i input3.mp4 \
#     -filter_complex \
#     "[0:v][1:v]hstack=inputs=2[top]; \
#     [2:v][3:v]hstack=inputs=2[bottom]; \
#     [top][bottom]vstack=inputs=2[v]" \
#     -map "[v]" \
#     finalOutput.mp4
