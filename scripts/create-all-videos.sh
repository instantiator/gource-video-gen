#!/bin/bash

# find . -type d -print0 | xargs -0 chmod go+rx

echo "Generating all videos..."

for REPO_PATH in repos/*; do
    [ -d "${REPO_PATH}" ] || continue # if not a directory, skip
    REPO_NAME="$(basename "${REPO_PATH}")"
    echo Found: $REPO_NAME
    ./run-gource.sh --repo $REPO_PATH
done
