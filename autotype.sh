#!/bin/bash
# types stdin out
# useful where copying via clipboard doesn't work

sleep "${1-2}"s
while read -r line; do
	xdotool type --delay 50 "$line"
	xdotool key Return
done
