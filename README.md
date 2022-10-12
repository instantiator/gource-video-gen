# gource-video-gen

Runs gource, creates video.

## Prerequisites

* Docker

## Usage

* Clone your favourite repositories inside `repos/`
* Launch gource inside Docker:

  ```sh
  generate-videos.sh
  ```

### Activity

* Scans `repos/`, assumes each directory is a repository
* For each repository:
    * Uses `xvfb` to run `gource` in "headless" mode
    * Uses `ffmpeg` to generate an mp4 from the gource output
    * Stores output mp4 in `results/`, named after the repository

## Options

* Optionally, put avatars into the avatars folder, match the _name_ of their account (not username), eg. `Firstname Lastname.png`
* Optionally, put a logo in the avatars folder, name it after its repository

## Coming soon

* Define gource options somehow (and override defaults)
* Put mp3s into the mp3s folder, name each after the repo, eg. `my-repository.mp3`
