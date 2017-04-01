#!/bin/bash
list_sort_files() (
    shopt -s nullglob dotglob
    # $1 should be a globbing pattern, like *
    files=($1)
    if [[ ${#files[@]} == 0 ]]; then
        exit
    fi
    mtime_id=()
    unsorted=()
    id=0
    for file in "${files[@]}"; do
        if ! mtime=$(stat -c %Y -- "$file"); then
            unsorted+=("x $id")
        else
            mtime_id+=("$mtime $id")
        fi
        ((id ++))
    done
    readarray -t mtime_id < <(printf '%s\n' "${mtime_id[@]}" | sort -n)
    sorted_files=()
    for m_i in "${mtime_id[@]}" "${unsorted[@]}"; do
        id=${m_i#*[^' ']' '}
        sorted_files+=("${files[id]}")
    done
    printf '%s\0' "${sorted_files[@]}"
)

files=()
while read -r -d ''; do
    files+=("$REPLY")
done < <(list_sort_files '*')

printf %s\\n "${files[@]}"
