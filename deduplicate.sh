#!/bin/bash
declare -A hashtable
while read -r line; do
    hash="${line%% *}"
    # empty file
    if [ "$hash" = "d41d8cd98f00b204e9800998ecf8427e" ]; then
		continue
	# fill
    elif [ "${hashtable["$hash"]}" = "" ]; then
        hashtable["$hash"]=${line#*  }
	# collision
    else
        printf '\n%s\n%s\n ' "${line#*  }" "${hashtable["$hash"]}"
    fi
done < <(find . -type f -exec md5sum {} +)
