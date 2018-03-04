#!/bin/bash
#todo: modularize:
# - see compress-Archive.sh
# - allow specification of gpg encrypted passphrase file

PassphraseFile="$(printf "$1" | sed 's/\(tar.xz\)\(.gpg\)\(\.000\)\{0,1\}/\1.txt\2/')"
[ -f "$PassphraseFile" ] || {
	printf "Error: Couldn't find gpg encrypted passphrase file\\n"
	exit 1
}

cat "$@" \
  | { gpg2 -qd --passphrase-fd 9 --cipher-algo AES256 --batch 9< \
      <(gpg -qd "$PassphraseFile")
    } 2> >(sed /"gpg: all values passed to '--default-key' ignored"/d) \
  | 7z e -an -si -so -txz \
  | tar -xf -
# > "${1//.000/}"
# | pv -petrab | tar -tf - >/dev/null
