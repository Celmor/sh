#!/bin/bash
# creates a random passphrase via openssl
# if file argument is given puts passphrase in it encrypted with default key by gpg
#todo:	no-echo option
#		passphrase length

file="$1"
pass="$(openssl rand -base64 63 | tr -d '\n')" || { printf %s\\n "Error: Couldn't create passphrase" && exit 1; }
if [ ! -f "$file" ] && [ -n "$file" ] && [ -d "$(dirname "$file")" ] && touch "$file" && [ -f "$file" ]; then
	printf %s "$pass" | gpg2 --yes -eqo "$file"
fi
printf %s\\n "$pass"
