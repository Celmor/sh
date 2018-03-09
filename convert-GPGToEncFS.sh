#!/bin/bash
Source="$1"
Target="$2"
User="$3"
Suffix="${4:-.gpg}"

set -e
cd "$Source" || exit 1
read -rs pass
for file in *"$Suffix"; do
    temp="$(mktemp "${file//.gpg/}.XXX")"
    if gpg2 --batch --yes --pinentry-mode loopback --passphrase "$pass" -o "$temp" -qd "$file"; then
        cp -a --attributes-only "$file" "$temp"
        sudo -u "$User" cp -ai "$temp" "$Target/${file//.gpg/}"
        rm "$file" "$temp"
    else
        sudo -u "$User" cp "$file" "$Target/$file.gpg.corrupt" && rm "$file"
    fi
done
