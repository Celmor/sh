#!/bin/bash
# author: celmor
# date: 2017-04-03
# v1.1 updated descriptions, tar archives files relative to parentdir now

# needs exactly 2 arguments
[ $# -eq 2 ] || {
    printf "%s\n" "Archives input (via tar and xz), puts the archive at output (can be dir or path) and deletes input (has to be confirmed), does support wildcards (use 'for' construct if needed)" >&2
    printf "%s\n" "Usage: $0 input outout" >&2
    printf "%s\n"  "input: path to archive and delete after archivation" >&2
    printf "%s\n" "output: path to put archive" >&2
    printf "%s\n" "example:" >&2
    printf "\t%s\n" "$0 input/ output.tar.xz" >&2
    printf "\t%s\n" "$0 inputfile output/ # creates output/input.xz" >&2
    printf "\t%s\n" "tar tf output # to verify archived items" >&2
    exit 1;
}

# test input arg
[ -e "$1" ] && input="$1" \
    || { printf "%s\n" "Error: input doesn't exist (execute with no arguments to print usage)" >&2 && exit 2; }

# test output arg
[ -d "$2" ] && output="$2/$1.tar.xz" \
    || [ -d "$(dirname "$2")" ] && output="$2" \
    || { printf "%s\n" "Error: output location doesn't exist (execute with no arguments to print usage)" >&2 && exit 3; }

# main work
tar -cJf "$output" -C "$(dirname "$input")" "$(basename "$input")" || exit
rm -rdI "$input" || { printf "%s\n" "Error: Couldn't delete all files" >&2 && exit; }
