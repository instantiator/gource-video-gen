#!/bin/bash

for REPO_PATH in repos/*; do
  [ -d "${REPO_PATH}" ] || continue # if not a directory, skip
  pushd $REPO_PATH
  git pull
  popd
done

