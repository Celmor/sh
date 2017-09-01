#!/bin/bash
# For editing files and outputting changes
temp=$(mktemp /tmp/${1##*/}.XXX)
cp "$1" "$temp"
vim "$1"
diff "$1" "$temp"
rm "$temp"
