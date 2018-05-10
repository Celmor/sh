#!/bin/bash
# deduplicate files in current path by searching for files with matching checksums (md5) and hardlinking them

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
        ln -f "${hashtable["$hash"]}" "${line#*  }"
    fi
done < <(find . -type f -exec md5sum {} +)
