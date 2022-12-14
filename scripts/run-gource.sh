#!/bin/bash

set -e
set -o pipefail

usage() {
  cat << EOF
Usage:
    -r         --repo              Path to the repository to use
    -o         --output-video-path Path to the output video to write to
    -a <bool>  --anonymise <bool>  Set true to anonymise (hide names, filenames, directories)
    -d <bool>  --no-date <bool>    Set true to hide the time/date
    -s <bool>  --no-skip <bool>    Don't skip quiet periods
    -dl <secs> --day-length <secs> Seconds per day
    -c         --captions          Path to the captions file to use
               --hide-root         Hides the root node (ie. when combining repositories)
    -t         --title             Title for the video
    -h         --help              Prints this help message and exits
EOF
}

# defaults
HIDE_ROOT=false
ANON=false
SCRIPT_PATH=$(dirname "$0")
NODATE=false
AUTOSKIP=1
SECS_PER_DAY=0.66

# parameters
while [ -n "$1" ]; do
  case $1 in
  -t | --title)
    shift
    TITLE=$1
    ;;
  -r | --repo)
    shift
    REPO_PATH=$1
    ;;
  -c | --captions)
    shift
    CAPTIONS_PATH=$1
    ;;
  -l | --logo-path)
    shift
    LOGO_PATH=$1
    ;;
  -o | --output-video-path)
    shift
    VIDEO_PATH=$1
    ;;
  -a | --anonymise)
    shift
    ANON=$1
    ;;
  -d | --no-date)
    shift
    NODATE=$1
    ;;
  -s | --no-skip)
    shift
    if $1; then
      AUTOSKIP=9999
    fi
    ;;
  -dl | --day-length)
    shift
    SECS_PER_DAY=$1
    ;;
  --hide-root)
    HIDE_ROOT=true
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

echo Generating video...
echo Title: $TITLE
echo Repository path: $REPO_PATH
echo Output path: $VIDEO_PATH
echo Avatars path: $AVATARS_PATH
echo Captions path: $CAPTIONS_PATH
echo Logo path: $LOGO_PATH
echo Anonymise: $ANON
echo Hide date: $NODATE
echo Autoskip: $AUTOSKIP
echo "Day length: $SECS_PER_DAY"

# backup previous video
if [ -e $VIDEO_PATH ]
then
    rm -f $VIDEO_PATH.backup
    mv $VIDEO_PATH $VIDEO_PATH.backup
fi

# prepare gource command to generate the video
GOURCE_CMD=$(cat << EOC
  gource -1280x720 --title $TITLE \
    --path $REPO_PATH \
    --user-image-dir $AVATARS_PATH \
    --output-framerate 25 \
    --seconds-per-day $SECS_PER_DAY \
    --highlight-users \
    --file-filter .*/\.idea/.* \
    --auto-skip-seconds $AUTOSKIP \
    -o -
EOC
)

# hiding things
HIDES=filenames
if $ANON; then
  HIDES="$HIDES,dirnames,usernames"
fi
if $NODATE; then
  HIDES="$HIDES,date"
fi
GOURCE_CMD="$GOURCE_CMD --hide $HIDES"

# hiding the root 
if $HIDE_ROOT; then
  GOURCE_CMD="$GOURCE_CMD --hide-root"
fi

# if the logo exists, tell gource about it
if [ -e $LOGO_PATH ]
then
  GOURCE_CMD="$GOURCE_CMD --logo $LOGO_PATH"
fi

# if the captions exist, tell gource about them
if [ -e $CAPTIONS_PATH ]
then
  GOURCE_CMD="$GOURCE_CMD --caption-file $CAPTIONS_PATH --caption-colour FFFF88"
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
#??--auto-skip-seconds 1 #??(default is 3)
#??--disable-auto-skip
#??--key
#??--bloom-multiplier 2.0 --bloom-intensity 1.5
#??-e 0.5 #??elasticity
#??--background 555555
#??--transparent
#??--background-image background.png
#??--date-format "%D" # uses strftime http://opengroup.org/onlinepubs/007908799/xsh/strftime.html
#??--font-size 18 --font-colour FFFF00
#??--logo logo.png
#??--logo-offset XxY
#??--title "My Project"
# --hide bloom,date,dirnames,files,filenames,mouse,progress,tree,users,usernames
