#!/bin/bash
#todo:	check if file can be created/already exists
#		remove Name line if title empty
#		optional: set display-name using "Name[en_US]=$(basename "$file")"
#		optional: get Title automatically
#		combine with ~/sh/new-URLShortCut.sh script
[ $# -ne 2 ] && printf "USAGE: %s FILE URL [TITLE]\\n" "$0"
file="$1"
url="$2"
title="$3"
printf %s "[Desktop Entry]
Encoding=UTF-8
Name="$title"
Type=Link
URL="$url"
Icon=text-html
"
> "$file"
