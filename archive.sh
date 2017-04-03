#!/bin/bash
# author: celmor
# date: 2017-04-03

usage() {
	printf "%s\n" "Archives input (via tar and xz), puts the archive at output (can be dir or path) and deletes input (has to be confirmed), does support wildcards (use 'for' construct if needed)" >&2
    printf "%s\n" "Usage: $0 input outout" >&2
    printf "%s\n"  "input: path to archive and delete after archivation" >&2
    printf "%s\n" "output: path to put archive" >&2
    printf "%s\n" "example:" >&2
    printf "\t%s\n" "$0 input/ output.tar.xz" >&2
    printf "\t%s\n" "$0 inputfile output/ # creates output/input.xz" >&2
    exit 1
}
[ $# -eq 2 ] || usage
[ -e "$1" ] && input="$1" \
	|| printf "%s\n"  "Error: input doesn't exist" >&2 && exit 2
[ -d "$2" ] && output="$2/$1.tar.xz" \
	|| [ -d "$(dirname "$2")" ] && output="$2"  >&2 && exit 3 \
	|| printf "%s\n"  "Error: output location doesn't exist"

tar -cJf "$output" -C "$(dirname "$output")" "$input" || exit 4
rm -rdI "$input"
