#!/bin/bash
# inserts stdin into FINE at LINE (overwriting lines)
[ $# -ne 2 ] && printf '%s\n' "Usage: $0 FILE LINE" && exit 1
input="$1"
line="$2"
i=0
output="/tmp/$(mktemp "$input"XXX)"
exiting(){
	mv "$output" "$input"
}
trap "exiting" EXIT
# read through file
while read -r out; do
	# if line I'm reading is lower than insert line copy line from intput into outpout
	if [[ $i -lt $line ]]; then
		echo "$out" >> "$output"
	else
		tee >> "$output"
		exit
	fi
	((i++))
done < <(cat "$input"; echo '')
# have read through file which means insert line is higher than lines currently existing in input file
for ((; i<=line; i++)); do
	#insert empty line
	echo '' >> "$output"
done
tee >> "$output"

