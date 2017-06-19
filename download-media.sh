#!/bin/bash
# Downloads Media with youtube-dl, expects h264 codec
Defaultdir="/Data/Download"
notification_daemon="twmnc"
cd "$Defaultdir" 2>/dev/null
while getopts "d:" opt; do
  case $opt in
    d)
      cd "$OPTARG"
      ;;
    \?)
      printf %s\\n "Usage: $0 [-d OUTPUTDIR] <URL> | <youtube-dl-args>"
      ;;
  esac
done
shift $((OPTIND-1))

notification="$notification_daemon -t \"Download finished:\" -c \"$(youtube-dl --get-title "$@")"\"
youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4' "$@" \
&& $nofication
