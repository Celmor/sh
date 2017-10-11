#!/bin/bash
# inserts TEXT into FILE at LINE (overwriting lines)
[ $# -ne 3 ] && printf '%s\n' "Usage: $0 \"FILE\" LINE \"TEXT\"" && exit 1
input="$1"
line="$2"
text="$3"
i=0
output="/tmp/$(mktemp "$(basename "$input")"XXX)"
exiting(){
	mv "$output" "$input"
}
trap "exiting" EXIT
# read through file
while read -r out; do
	# if line I'm reading is lower than insert line copy line from intput into ]ut
	if [[ $i -lt $line ]]; then
		echo "$out" >> "$output"
	else
		echo "$text" >> "$output"
		exit
	fi
	((i++))
done < <(cat "$input"; echo '')
# have read through file which means insert line is higher than lines currently existing in input file
for ((; i<=line; i++)); do
	#insert empty line
	echo '' >> "$output"
done
echo "$text" >> "$output"
