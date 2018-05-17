#!/bin/bash
# deduplicate files in current path by searching for files with matching checksums (md5) and hardlinking them
# WARNING: cannot handle file names with new lines

[ $# -eq 1 ] && [ "$1" = "-i" ] && interactive="true" || [ $# -eq 0 ] || \
    printf 'USAGE: %s [-i]' "$0"
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
        printf 'linking: '\''%s'\''\n' "${hashtable["$hash"]}"
        ln -f ${interactive:+"-i"} "${hashtable["$hash"]}" "${line#*  }"
    fi
done < <(find . -type f -exec md5sum {} +)
