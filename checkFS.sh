#!/bin/bash
fs="$1"
if ! mountpoint -q "$fs"; then
	printf "ERROR: %s isn't a mountpoint\\n"
	exit 1
fi
file="$(mktemp -tp "$fs" checkFS.XXX)"
avail="$(($(
	df --sync -k --output=avail "$fs" | tail -1
	)/1024-1))M"
trap 'rm "$file"' SIGINT
pv -petrabSs "$avail" /dev/urandom \
	| tee "$fs"/rand \
	| md5sum
md5sum "$file"
