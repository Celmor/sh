#!/bin/bash
#Print DU Matrix

#declare -A du # matrix
#declare -a Roots # rows
declare -a Dirs # columns
Roots=( VM/win10 VM/win10-cracked VM/win10-online VM/win10rolledBack VM/winNew ) # $@

#Collect Dirs
for ((RootIndex=0; RootIndex< ${#Roots[@]}; RootIndex ++)); do
	for CurrentDirInCurrentRoot in ${Roots[$RootIndex]}/*; do
		echo "${Dirs[@]}" | grep -q "${CurrentDirInCurrentRoot##*/}" && continue
		count=0
		for Root in "${Roots[@]}"; do
			[ -e "$CurrentDirInCurrentRoot" ] && ((count++))
		done
		[ "$count" -gt 1 ] && Dirs+=( "${CurrentDirInCurrentRoot##*/}" )
	done
done
echo "${Dirs[@]}"
