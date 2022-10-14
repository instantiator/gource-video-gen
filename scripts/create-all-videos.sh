#!/bin/bash

set -e
set -o pipefail

usage() {
  cat << EOF
Usage:
    -c      --combine           Combine all repository histories and captions
    -t      --title             Title for the combined video (use with --combine)
    -h      --help              Prints this help message and exits
EOF
}

while [ -n "$1" ]; do
  case $1 in
  -c | --combine)
    shift
    COMBINE=$1
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

echo "Generating all videos..."
echo Combine repositories: $COMBINE

if $COMBINE; then
  # generate repository histories
  for REPO_PATH in repos/*; do
    [ -d "${REPO_PATH}" ] || continue # if not a directory, skip
    REPO_NAME="$(basename "${REPO_PATH}")"
    echo Found: $REPO_NAME
    LOG_PATH=repos/$REPO_NAME.log.txt
    gource --output-custom-log $LOG_PATH $REPO_PATH
    sed -i -r "s#(.+)\|#\1|/${REPO_NAME}#" $LOG_PATH
  done

  # combine histories
  COMBINED_LOG_PATH=repos/all-repos.log.combined.txt
  cat repos/*.log.txt | sort -n > $COMBINED_LOG_PATH

  # combine captions
  COMBINED_CAPTIONS_PATH=captions/combined.captions
  cat captions/*.txt | sort -n > $COMBINED_CAPTIONS_PATH

  # build video from combined histories and captions
  SILENT_VIDEO_PATH=results/combined.silent.mp4
  ./run-gource.sh \
    --title "$TITLE" \
    --repo "$COMBINED_LOG_PATH" \
    --output-video-path "$SILENT_VIDEO_PATH" \
    --captions "$COMBINED_CAPTIONS_PATH" \
    --logo-path avatars/combined.png \
    --hide-root

  AUDIO_PATH=mp3s/combined.mp3
  VIDEO_PATH=results/combined.mp4
  if [ -e $AUDIO_PATH ]
  then
      ./apply-audio.sh \
        --input-video "$SILENT_VIDEO_PATH" \
        --input-audio "$AUDIO_PATH" \
        --output-video "$VIDEO_PATH"
  else
      mv "$SILENT_VIDEO_PATH" "$VIDEO_PATH"
  fi

else
  # generate a video for each repository
  for REPO_PATH in repos/*; do
    [ -d "${REPO_PATH}" ] || continue # if not a directory, skip
    REPO_NAME="$(basename "${REPO_PATH}")"
    echo Found: $REPO_NAME
    AUDIO_PATH=mp3s/$REPO_NAME.mp3
    VIDEO_PATH=results/$REPO_NAME.mp4
    SILENT_VIDEO_PATH=results/$REPO_NAME.silent.mp4
    CAPTIONS_PATH=captions/$REPO_NAME.txt
    LOGO_PATH=avatars/$REPO_NAME.png
    ./run-gource.sh \
      --title $REPO_NAME \
      --repo "$REPO_PATH" \
      --captions "$CAPTIONS_PATH" \
      --output-video-path "$SILENT_VIDEO_PATH" \
      --logo-path "$LOGO_PATH"

    if [ -e $AUDIO_PATH ]
    then
        ./apply-audio.sh \
          --input-video "$SILENT_VIDEO_PATH" \
          --input-audio "$AUDIO_PATH" \
          --output-video "$VIDEO_PATH"
    else
        mv "$SILENT_VIDEO_PATH" "$VIDEO_PATH"
    fi
  done
fi


