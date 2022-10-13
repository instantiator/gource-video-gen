#!/bin/bash

set -e
set -o pipefail

usage() {
  cat << EOF
Usage:
    -r      --repo              Path to the repository to use
    -o      --output-video-path Path to the output video to write to
    -h      --help              Prints this help message and exits
EOF
}

while [ -n "$1" ]; do
  case $1 in
  -r | --repo)
    shift
    REPO_PATH=$1
    ;;
  -o | --output-video-path)
    shift
    VIDEO_PATH=$1
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

REPO_NAME=$(basename $REPO_PATH)
AVATARS_PATH=avatars/
LOGO_PATH=avatars/$REPO_NAME.png

echo Generating video...
echo Repository path: $REPO_PATH
echo Output path: $VIDEO_PATH

# backup previous video
if [ -e $VIDEO_PATH ]
then
    rm -f $VIDEO_PATH.backup
    mv $VIDEO_PATH $VIDEO_PATH.backup
fi

# prepare gource command to generate the video
GOURCE_CMD=$(cat << EOC
  gource -1280x720 --title $REPO_NAME \
    --path $REPO_PATH \
    --user-image-dir $AVATARS_PATH \
    --output-framerate 25 \
    --seconds-per-day 0.5 \
    --hide filenames \
    --highlight-users \
    --file-filter ^\. \
    --auto-skip-seconds 1 \
    -o -
EOC
)

# if the logo exists, tell gource about it
if [ -e $LOGO_PATH ]
then
  GOURCE_CMD="$GOURCE_CMD --logo $LOGO_PATH"
fi

# generate new video
echo Generating video with gource...
echo $GOURCE_CMD
xvfb-run $GOURCE_CMD | ffmpeg -i - $VIDEO_PATH

# common gource options, for reference...

# -1280x720 # dimensions or 854x480 (smaller)
# --camera-mode track
# --start-position 0.5 --stop-position 0.75
#    --start-position 0.001 --stop-position 0.1 \
# --seconds-per-day 1
# --auto-skip-seconds 1 # (default is 3)
# --disable-auto-skip
# --key
# --bloom-multiplier 2.0 --bloom-intensity 1.5
# -e 0.5 # elasticity
# --background 555555
# --transparent
# --background-image background.png
# --date-format "%D" # uses strftime http://opengroup.org/onlinepubs/007908799/xsh/strftime.html
# --font-size 18 --font-colour FFFF00
# --logo logo.png
# --logo-offset XxY
# --title "My Project"
# --hide bloom,date,dirnames,files,filenames,mouse,progress,tree,users,usernames
