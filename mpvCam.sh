#!/bin/bash
cam=$1
url=$2
if [[ $# -eq 2 && "$cam" =~ ^[0-9]+$ && ! "$url" =~ ( |\') ]]; then
    echo "Receiving URL"...
    mapfile -t temp < <(youtube-dl -g --playlist-items $cam $url)
    mpv "${temp[0]}" --audio-file="${temp[1]}" 2>&1 | grep -v libva
else
    echo "Wrong input: $0 <Cam> <URL>"
fi
