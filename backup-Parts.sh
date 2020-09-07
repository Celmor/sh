#!/bin/bash
# v3.2 - add checks, comments

#---------- VARS ----------
ChunkSize=128K # divided by 8K
i=0
_help() {
  printf "Usage: %s [-v] [-c] [-f SFVFILE] [-s CHUNKSIZE] [-n NAME] [-i STARTVALUE] [INPUT]\n" "$0" >&2
  printf "\t-v\tverbose output\n" >&2
  printf "\t-c\tenable compression of input\n" >&2
  printf "\t-i\tset start value of incremented part number\n" >&2
  exit 1
}
while getopts "vf:n:s:ci:" opt; do
  case $opt in
    v)
      verbose="true"
      ;;
    f)
      sfv="${OPTARG}"
      printf "Not yet supportedn" >&2
      exit 1
      ;;
    n)
      prefix="${OPTARG}"
      ;;
    s)
      ChunkSize="${OPTARG}"
      ;;
    c)
      compression=on
      ;;
    i)
      i="${OPTARG}"
      ;;
    \?)
      _help
      ;;
  esac
done
shift $((OPTIND-1))

# read from stdin
if [ $# -eq 0 ] || { [ $# -eq 1 ] && [ "$1" = "-" ]; } then
  if [ ! "$prefix" ]; then
    printf "Syntax Error: Name required if input is stdin\n" >&2
    exit 1
  fi
  input=/dev/stdin
# read from file given by arg "$1"
elif [ $# -eq 1 ]; then
  input="$1"
  prefix=$(basename "$2")
else
  _help
fi

output=$(printf '%s.%03d' "$prefix" "$i")
cache=/tmp/$(mktemp "$prefix".XXX)
remote="CryptDrive-BackupDisk"
trapfunc() { [ "$verbose" ] && printf "\nTrapped at file:\t%s\n" "$output" && ls -l "$cache"; rm -f -- "$cache"; }
trap trapfunc exit
set -e

#---------- main ----------
#todo check sfv file

#create backups from stdin
while output=$(printf '%s.%03d' "$prefix" $i); i=$((i+1)) #todo: append .gz to output if $compression set
      dd iflag=fullblock bs=8K count="$ChunkSize" of="$cache" 2>/dev/null \
      && [ -s "$cache" ]
do
  printf '%s %s\n' "$output" "$(cksfv -qc "$cache" | awk 'END { print $NF }')" >> "$prefix.sfv"
  [ "$verbose" ] && tail -1 "$prefix.sfv"
  [ "$compression" ] && nice pigz "$cache" && cache="${cache}.gz"
  rclone moveto --fast-list ${verbose:+-P --stats-one-line} "$cache" "$remote":"$prefix/$output"
  [ "$compression" ] && cache="${cache%.gz}"
done < "$input"
rclone moveto --fast-list ${verbose:+-P --stats-one-line} "$prefix.sfv" "$remote":"$prefix/$prefix.sfv"
