#!/bin/sh
set -o pipefail
url="https://ptpb.pw"
if [ "$1" = "-h" ]; then
	printf "USAGE: %s [-d]
	Creates a paste of clipboard content
	Deletes last paste created with this script\\n" "$0"
	exit
elif [ "$1" = "-d" ]; then
	paste="$(ls -t /tmp/paste* | head -1)"
	uuid="$(grep uuid: "$paste" | awk '{ print $2 }')" || exit 1
	curl -X DELETE "$url"/"$uuid" > "$paste"
	exit
fi
xclip -o | curl -F c=@- "$url" | tee "$(mktemp /tmp/paste.XXX)" | awk '/url:/ { print $2 }' | xclip -sel clip || exit 1
