#!/bin/bash
cd /Data/Download
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

youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4' $@
twmnc -t "Download finished:" -c "$(youtube-dl --get-title $@)"
