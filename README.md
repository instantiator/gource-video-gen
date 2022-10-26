# gource-video-gen

Runs gource, creates videos. Simplifies mixing in audio, captions, a logo, and a title.

## Prerequisites

* Docker

## Generate videos

* Run `./init-directories.sh` to create input and results directories.
* Clone your favourite repositories inside `repos/`
* Launch gource inside Docker:

  ```sh
  ./generate-videos.sh
  ```

### Options

```
Options:
    -c         --combine              Combines histories and captions for all repositories found
    -a         --anonymise            Generates anonymous video (no names, no directories, no filenames)
    -d         --no-date              Hide the time/date
    -s         --no-skip              Don't skip quiet periods
    -dl <secs> --day-length <secs>    Seconds per day (default = 0.66)
    -t         --title                Title for the combined video (use with --combine)
    -h         --help                 Prints this help message and exits
```

### Activity

* Scans `repos/`, assumes each directory is a repository
  * Uses `xvfb` to run `gource` in "headless" mode
  * Uses `ffmpeg` to generate an mp4 from the gource output
  * Stores output mp4 in `results/`, named after the repository

### Optional enhancements

* Enabled combination of all repositories into a single video with `--combined` (or `-c`)
  * Set a title with `--title <title>` for the whole set.
* Use `./init-directories.sh` to create the initial directories.
* Put avatars into the avatars folder, match the _name_ of their account (not username), eg. `Firstname Lastname.png`
* Put a logo in the `avatars/` folder, name it after its repository eg. `my-repository.png` _or_ `combined.png`
* Put mp3s into the `mp3s/` folder, name each after the repo, eg. `my-repository.mp3` _or_ `combined.mp3`

### Combined videos

When generating a combined video with the `-c` or `--combined` option, all file paths are prefixed with the name of the repository. This generates a central point from which all repositories start.

The `--hide-root` option is automatically used, which _ought_ to hide the first lines, so ensuring the repositories look distinct.

However, if not all repositories start at the same time, this will hide the lines linking the top level directories in the first active repository, until the other repositories join it.

That looks a little messy. It can be solved by adding a supplementary log file (see below) with a "fake" first file, matching the earliest entry from the first active repository.

eg. Create: `repos/supplementary.log.txt`

```
1641254400|Lewis Westbury|A|/init.txt
```

### Log files

Gource uses log files generated from each repository. You can create supplementary logs to add extra actions not found in the repositories used to make each video.

This is particularly helpful when creating a combined video.

* Put the supplementary logs in `repos/*.log.txt` (all filenames accepted)
* The format is: `<unix timestamp>|<User name>|<A/M/D>|<path>`

eg.

```
1641254400|Lewis Westbury|A|/init.txt
```

* `A` = Add
* `M` = Modify
* `D` = Delete
* Paths start with `/`

### Captions files

* Put a captions file into the `captions/` folder, name after the repo, eg. `my-repository.txt`
* All captions files will be automatically combined if the `--combined` option is enabled
* The format is: `<unix timestamp>|<caption>`

eg.

```
1275543595|John joins the project
1327553595|Version 1.0 released
```


### Unix timestamps

If you want to generate unix timestamps from a Google Sheet, use this formula to calculate one from a date field:

```
=INT((A2-("1/1/1970"-"1/1/1900"+2))*86400)
```

Here, `A2` is the cell containing the date.

Concatenate the timestamp and caption with:

```
=CONCATENATE(B2,"|",C2)
```

Here, `B2` contains the timestamp, and `C2` contains the caption you wish to use.

## Generate video grid

* First generate the videos you wish to use inside `results`. (You'll need a square number of videos, they'll all need the same dimensions, but different durations are ok.)
* Launch inside Docker:

  ```sh
  ./generate-videos.sh -w <int> -h <int>
  ```

**NB. At current time, this script will return the ffmpeg command you need to run to generate the new grid video.**
Just copy and paste it to use it.

### Options

```
Options:
    -w <n>  --width <n>         Number of videos wide
    -h <n>  --height <n>        Number of videos tall
            --help              Prints this help message and exits
```

### Activity

* Scans `results/`, and uses the videos it finds in the order it finds them (not well defined yet)
* Regenerates and uses `results/durations.csv` to determine by how much to delay each video
* Uses `ffmpeg` to generate a grid of WxH videos, with each video delayed so they all finish together

## Known issues

* Any title provided in `--title` has to be 1 word. I haven't figured out why inverted commas isn't helping.
* Order of videos used by the grid script is not well defined.
* Audio is not retained from videos in the grid script - you'll need to apply it yourself afterwards.

## Coming soon

* Define and pass through gource options
