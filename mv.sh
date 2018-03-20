#!/bin/bash

# help
if [ "$1" = "-h" ]; then
	printf "Usage: $0 SOURCE TARGET\\n"
	exit 0
# move operation
elif [ "$#" -eq 2 ] && [ -e "$1" ]; then
	source="$1"
	target="$2"
	# move $source into $target/ and symlink back
	if [ -d "$target" ]; then
		mv "$source" "$target"/ && ln -s "$target"/"$(basename "$source")" "$source"
	# $target exists and is not a folder
	elif [ -e "$target" ]; then
		printf "error: %s exists and is not a folder\\n" "$target"
		exit 1
	# $target doesn't exist
	else
		mv "$source" "$target" && ln -s "$target" "$source"
	fi
# unsupported operation
else
	printf "error: Invalid arguments\\n"
	exit -1
fi
