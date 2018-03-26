#!/bin/bash
IndexWildcard="$1"
OpenWith="$2"
shift 2
Files="$@"

for ((i=1; i<=${#Files[@]}; i++)); do
	if [[ "$(readlink -f "${Files[$i]}")" = "$(readlink -f $IndexWildcard)" ]]; then
		index=$i
		break
	fi
	printf "IndexWildcard not found\\n" >&2; exit 1
done
"${OpenWith:-:}" "${Files[$index]}" || exit
