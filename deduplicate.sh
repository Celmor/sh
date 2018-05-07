#!/bin/bash
declare -A hashtable
while read -r line; do
    hash="${line%% *}"
    if [ "${hashtable["$hash"]}" = "" ]; then
        hashtable["$hash"]=${line#*  }
    else
        printf '%s\n%s\n\n' "${line#*  }" "${hashtable["$hash"]}"
    fi
done < <(find . -type f -exec md5sum {} +)
