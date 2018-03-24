#!/bin/bash
if [ "$#" -ne 1 ]; then
  printf "Usage: %s SERVER" "$0"
fi
 printf '%s\t\t%s\n' "TIME" "PACKET DELAY (MS)"
ping "$1" | \
  while read -r line; do
    if [[ "$line" =~ .*icmp_seq=.* ]]; then
      printf '%d\t%s\n' "$(date +%s)" "$(
      printf '%s\n' "$line" | sed 's/.* time=\([0-9\.]*\) .*/\1/')"
    else
      printf '%d\t%s\n' "$(date +%s)" "999"
    fi
  done
