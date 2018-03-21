#!/bin/bash
cam=$1
url=$2
if [[ $# -eq 2 && "$cam" =~ ^[0-9]+$ && ! "$url" =~ ( |\') ]]; then
    echo "Receiving URL"...
    mpv "$(youtube-dl -g --playlist-items $cam $url)"
else
    echo "Wrong input: $0 <Cam> <URL>"
fi
