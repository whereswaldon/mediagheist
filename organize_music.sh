#!/bin/bash

if ! which ffprobe > /dev/null 2>&1; then
	echo "Missing dependency: ffprobe (part of ffmpeg)"
	exit 1
elif ! which jq > /dev/null 2>&1; then
	echo "Missing dependency: jq"
	exit 1
elif ! which inline-detox > /dev/null 2>&1; then
	echo "Missing dependency: inline-detox (part of detox)"
	exit 1
fi

if [[ "$#" < 1 ]]; then
	scriptname=$(basename "$0")
	echo -e "$scriptname: Organize a directory of MP3 files into subdirectories of ~/Music\nUsage: $scriptname <directory>"
	exit 1
fi
MUSICDIR="$HOME/Music"
FLATDIR="$MUSICDIR/flat"
ALBUMDIR="$MUSICDIR/albums"
ARTISTDIR="$MUSICDIR/artists"
if ! mkdir -p "$FLATDIR"; then
	echo "Unable to create $FLATDIR"
	exit 1
elif ! mkdir -p "$ALBUMDIR"; then
	echo "Unable to create $ALBUMDIR"
	exit 1
elif ! mkdir -p "$ARTISTDIR"; then
	echo "Unable to create $ARTISTDIR"
	exit 1
fi
for file in "$1"/*; do
	detox_file=$(basename "$file" | inline-detox)
	final_path="$FLATDIR/$detox_file"
	metadata=$(ffprobe "$file" -print_format json -show_format -show_streams 2> /dev/null)
	format=$(echo "$metadata" | jq '.format.format_name' | tr -d '"')
	if [[ "$format" == "mp3" ]]; then
            album=$(echo "$metadata" | jq '.format.tags.album' | inline-detox)
            artist=$(echo "$metadata" | jq '.format.tags.artist' | inline-detox)
	elif [[ "$format" == "ogg" ]]; then
            album=$(echo "$metadata" | jq '.streams[].tags.ALBUM' | head -1 | inline-detox)
            artist=$(echo "$metadata" | jq '.streams[].tags.ARTIST' | head -1 | inline-detox)
	else
		echo "unknown format, skipping"
		continue
	fi
	curr_album_dir="$ALBUMDIR/$album"
	curr_artist_dir="$ARTISTDIR/$artist"
	if [ ! -d "$curr_album_dir" ] && [ ! -L "$curr_album_dir" ]; then
		echo "No directory at $curr_album_dir, creating..."
		if ! mkdir -p "$ALBUMDIR/$album"; then
        		echo "Unable to create $curr_album_dir"
        		exit 1
		fi
	fi
	if [ ! -d "$curr_artist_dir" ] && [ ! -L "$curr_artist_dir" ]; then
		echo "No directory at $curr_artist_dir, creating..."
		if ! mkdir -p "$ARTISTDIR/$artist"; then
        		echo "Unable to create $curr_artist_dir"
        		exit 1
		fi
	fi
	if [ ! -f "$final_path" ] && ! mv "$file" "$final_path"; then
		echo "Unable to move $file"
	fi
	if [ ! -L "$curr_album_dir/$detox_file" ] && ! ln -s "$final_path" "$curr_album_dir/$detox_file"; then
		echo "Unable to link $file"
	fi
	if [ ! -L "$curr_artist_dir/$detox_file" ] && ! ln -s "$final_path" "$curr_artist_dir/$detox_file"; then
		echo "Unable to link $file"
	fi
done
