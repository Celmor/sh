#!/bin/bash
if [ "$(df --output=fstype "$@" | tail -1)" = tmpfs ]; then
	mpv -- "$@" &
	sleep 0.5
	rm -f "$@"
	wait
else
	mpv -- "$@"
fi

