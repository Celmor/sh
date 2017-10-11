#!/bin/bash
# inserts TEXT into FILE at LINE
[ $# -ne 3 ] && printf '%s\n' "Usage: $0 \"FILE\" LINE \"TEXT\"" && exit 1
file="$1"
line="$2"
text="$3"
output=""
i=0
# read through file
while read -r out ; do
        # add all lines before insert position to buffer
        for (( ; i < line ; i++)); do
                output+="$out"'\n'
        done
        # add insert text to buffer
        output+="$text"'\n'
        # add remaining lines to buffer
	output+="$out"'\n'
done < <(printf '%s\n' "$file")
# have read through file and filled buffer
# now flush buffer to file
printf %s > "$file"
