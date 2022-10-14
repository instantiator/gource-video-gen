# gource-video-gen

Runs gource, creates video.

## Prerequisites

* Docker

## Usage

* Clone your favourite repositories inside `repos/`
* Launch gource inside Docker:

  ```sh
  ./generate-videos.sh
  ```

### Activity

* Scans `repos/`, assumes each directory is a repository
  * Uses `xvfb` to run `gource` in "headless" mode
  * Uses `ffmpeg` to generate an mp4 from the gource output
  * Stores output mp4 in `results/`, named after the repository

## Optional enhancements

* Enabled combination of all repositories into a single video with `--combined`
  * Set a title with `--title <title>` for the whole set.
* Use `./init-directories.sh` to create the initial directories.
* Put avatars into the avatars folder, match the _name_ of their account (not username), eg. `Firstname Lastname.png`
* Put a logo in the `avatars/` folder, name it after its repository eg. `my-repository.png` _or_ `combined.png`
* Put mp3s into the `mp3s/` folder, name each after the repo, eg. `my-repository.mp3` _or_ `combined.mp3`
* Put a captions file into the `captions/` folder, name after the repo, eg. `my-repository.txt`
  * All captions files will be automatically combined if the `--combined` option is enabled

### Captions files

Add a unix timestamp and caption, pipe `|` separated, per line.

eg.

```
1275543595|John joins the project
1327553595|Version 1.0 released
```

If you want to generate this from a Google Sheet, use this formula to calculate a unix timestamp from a date field:

```
=INT((A2-("1/1/1970"-"1/1/1900"+2))*86400)
```

Concatenate the timestamp and caption with:

```
=CONCATENATE(B2,"|",C2)
```

## Known issues

* Any title provided in `--title` has to be 1 word. I haven't figured out why inverted commas isn't helping.

## Coming soon

* Define and pass through gource options
