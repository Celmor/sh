#!/bin/bash
# lists saved sources from MPV
# setting requried for MPV (before quit-watch-later command is sued in mpv, which is bound to Q by default)
# for this script to work as intended: write-filename-in-watch-later-config=yes

cd ${HOME}/.config/mpv/watch_later/ &&
readarray -t watch_later < <(/usr/bin/ls -t) &&
for index in "${!watch_later[@]}"; do
	head -1 ./"${watch_later[index]}"
done |
/usr/bin/grep ^# |
sed 's/# //'
