# mediagheist

Currently, this repo is for scripts that I wrote to manage my media files. I 
wanted to expose information about the artist and album for music files without 
using some kind of restrictive naming convention. What I came up with works 
like this:

- All music files live in `~/Music/flat`
- Each artist and album has a directory in `~/Music/albums` or `~/Music/artists`
  - Within a given artist's or album's directory is a symbolic link to each 
music file belonging to that artist.

This has the benefit that all of the music files only need to exist in one 
place, but can be viewed in the filesystem through multiple hierarchies.

## Drawbacks

- Only handles MP3 files
- Doesn't handle all possible metadata for sorting, just artist and album

## Plans

- Support multiple media containers (OGG, etc...)
- Create scripts to do similar tasks for other media types

## Install

```
git clone https://github.com/whereswaldon/mediagheist
cd mediagheist
chmod +x organize_music.sh

# optional
cp organize_music.sh ~/.local/bin
```

## Usage

```
./organize_music.sh <path-to-dir-with-mp3s>
```
