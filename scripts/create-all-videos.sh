#!/bin/bash

set -e
set -o pipefail

usage() {
  cat << EOF
Usage:
    -c         --combine           Combine all repository histories and captions
    -a <bool>  --anonymise <bool>  Anonymous videos - hide names, filenames, directories
    -d <bool>  --no-date <bool>    Hide the date/time
    -s         --no-skip           Don't skip quiet periods
    -dl <secs> --day-length <secs> Seconds per day
    -t         --title             Title for the combined video (use with --combine)
    -h         --help              Prints this help message and exits
EOF
}

# defaults
COMBINE=false
ANON=false
SCRIPT_PATH=$(dirname "$0")
NODATE=false
NOSKIP=false
SECS_PER_DAY=0.66

# parameters
while [ -n "$1" ]; do
  case $1 in
  -c | --combine)
    shift
    COMBINE=$1
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
    NOSKIP=$1
    ;;
  -dl | --day-length)
    shift
    SECS_PER_DAY=$1
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

echo "Creating all videos..."
echo Combine repositories: $COMBINE
echo Anonymise: $ANON
echo Hide date: $NODATE
echo No skip: $NOSKIP
echo "Day length: $SECS_PER_DAY (secs)"

# working directory
WORK=work
mkdir -p $WORK

if $COMBINE; then
  # empty working directory
  rm -rf $WORK/*

  # copy in all supplementary logs (don't fail if not found)
  cp repos/*.log.txt $WORK/

  # generate repository logs
  for REPO_PATH in repos/*; do
    [ -d "${REPO_PATH}" ] || continue # if not a directory, skip
    REPO_NAME="$(basename "${REPO_PATH}")"
    echo Found: $REPO_NAME

    # generate log
    LOG_PATH=$WORK/$REPO_NAME.log.txt
    gource --output-custom-log $LOG_PATH $REPO_PATH

    # prefix all paths in the log with the repo name
    sed -i -r "s#(.+)\|#\1|/${REPO_NAME}#" $LOG_PATH
  done

  # combine logs
  COMBINED_LOG_PATH=$WORK/all-repos.log.combined.txt
  cat $WORK/*.log.txt | sort -n > $COMBINED_LOG_PATH

  # combine captions
  COMBINED_CAPTIONS_PATH=$WORK/combined.captions
  cat captions/*.txt | sort -n > $COMBINED_CAPTIONS_PATH

  # video paths
  if $ANON; then
    SILENT_VIDEO_PATH=results/combined.anon.silent.mp4
    VIDEO_PATH=results/combined.anon.audio.mp4
  else
    SILENT_VIDEO_PATH=results/combined.silent.mp4
    VIDEO_PATH=results/combined.audio.mp4
  fi

  # build video from combined histories and captions
  $SCRIPT_PATH/run-gource.sh \
    --title "$TITLE" \
    --repo "$COMBINED_LOG_PATH" \
    --output-video-path "$SILENT_VIDEO_PATH" \
    --captions "$COMBINED_CAPTIONS_PATH" \
    --logo-path avatars/combined.png \
    --anonymise "$ANON" \
    --no-date "$NODATE" \
    --no-skip "$NOSKIP" \
    --day-length "$SECS_PER_DAY" \
    --hide-root

  AUDIO_PATH=mp3s/combined.mp3
  if [ -e $AUDIO_PATH ]
  then
    $SCRIPT_PATH/apply-audio.sh \
      --input-video "$SILENT_VIDEO_PATH" \
      --input-audio "$AUDIO_PATH" \
      --output-video "$VIDEO_PATH"
  else
    # mv "$SILENT_VIDEO_PATH" "$VIDEO_PATH"
    echo "No audio to apply"
  fi

else
  # generate a video for each repository
  for REPO_PATH in repos/*; do
    [ -d "${REPO_PATH}" ] || continue # if not a directory, skip
    REPO_NAME="$(basename "${REPO_PATH}")"
    echo Found: $REPO_NAME

    # empty working directory
    rm -rf $WORK/*

    # copy in all supplementary logs
    cp repos/*.log.txt $WORK/

    # generate repository log
    LOG_PATH=$WORK/$REPO_NAME.log.txt
    gource --output-custom-log $LOG_PATH $REPO_PATH

    # combine with supplementary logs
    COMBINED_LOG_PATH=$WORK/all-repos.log.combined.txt
    cat $WORK/*.log.txt | sort -n > $COMBINED_LOG_PATH

    # video paths
    if $ANON; then
      SILENT_VIDEO_PATH=results/$REPO_NAME.anon.silent.mp4
      VIDEO_PATH=results/$REPO_NAME.anon.audio.mp4
    else
      SILENT_VIDEO_PATH=results/$REPO_NAME.silent.mp4
      VIDEO_PATH=results/$REPO_NAME.audio.mp4
    fi

    # generate video for the repo
    CAPTIONS_PATH=captions/$REPO_NAME.txt
    LOGO_PATH=avatars/$REPO_NAME.png
    $SCRIPT_PATH/run-gource.sh \
      --title $REPO_NAME \
      --repo "$COMBINED_LOG_PATH" \
      --captions "$CAPTIONS_PATH" \
      --output-video-path "$SILENT_VIDEO_PATH" \
      --logo-path "$LOGO_PATH" \
      --anonymise "$ANON" \
      --no-skip "$NOSKIP" \
      --day-length "$SECS_PER_DAY" \
      --no-date "$NODATE"

    AUDIO_PATH=mp3s/$REPO_NAME.mp3
    if [ -e $AUDIO_PATH ]
    then
      $SCRIPT_PATH/apply-audio.sh \
        --input-video "$SILENT_VIDEO_PATH" \
        --input-audio "$AUDIO_PATH" \
        --output-video "$VIDEO_PATH"
    else
      # mv "$SILENT_VIDEO_PATH" "$VIDEO_PATH"
      echo "No audio to apply"
    fi
  done
fi

# capture video durations (and rename video files by duration)
$SCRIPT_PATH/get-video-durations.sh > results/durations.csv
cat results/durations.csv
