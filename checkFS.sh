#!/bin/bash

fs="$1"
if ! mountpoint -q "$fs"; then
    printf "ERROR: \""%s\"" isn't a mountpoint\\n"
    exit -1
fi
file="$(mktemp -tp "$fs" checkFS.XXX)"
availM=$(($(df --sync -k --output=avail "$fs" | tail -1)/1024-1))
if [ "$availM" -le 0 ]; then
    printf "ERROR: Error: Not enough free space on %s\\n" "$fs"
    exit -1
fi

trap 'rm "$file"' SIGINT EXIT
Sum="$(pv -petrabSs "${availM}M" /dev/urandom \
    | tee "$file" \
    | md5sum \
    | awk '{ print $1}'
)"
if [ "$Sum" != "$(md5sum "$file" | awk '{ print $1}')" ]; then
    printf %s\\n "Verification failed!"
    exit 1
fi
#md5sum --quiet -c <(printf "%s  %s\\n" "$Sum" "$file")
