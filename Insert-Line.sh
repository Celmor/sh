#!/bin/bash
# inserts TEXT into FILE at LINE
[ $# -ne 3 ] && printf '%s\n' "Usage: $0 \"FILE\" LINE \"TEXT\"" && exit 1
file="$1"
[ -f "$file" ] || printf '%s\n' "Error: \"$file\" is not a regular file" && exit 1
line="$2"
[ "$line" -lt 0 ] || printf '%s\n' "Error: \"$line\" is invalid line number" && exit 1
text="$3"
[ -n "$text" ] || printf '%s\n' "Error: No input text" && exit 1
output=""
i=0 # count line number from this value up

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
