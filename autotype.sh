#!/bin/bash
# types stdin out
# useful where copying via clipboard doesn't work
sleep "$1"s
while read -r line; do
	xdotool type "$line"
	xdotool key Return
done
