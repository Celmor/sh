#!/bin/bash
set -e

sources=("${@:2}")
target=$1
date=$(date +d%F-%H-%M)
declare -a errors
[ $# -lt 2 ] && { printf "Usage: %s DEST SOURCE..." "$0"; exit; }

mountpoint -q "$target" || errors+=("Error: Destination not a mountpoint: $target")
fs=$(zfs get -Ho value name "$target")
for source in "${sources[@]}"; do
    [ -d "$source" ] || errors+=("Error: dir doesn't exist: $source")
done
if [ ${#errors[@]} -gt 0 ]; then
    printf "%s\n" "${errors[@]}" >&2
    exit 1
fi

rsync -axHAX --delete "${sources[@]}" "$target"/
zfs snapshot "$fs@$date"