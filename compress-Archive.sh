#!/bin/bash
#todo: modularize:
# - find common parent dir
# - encryption and passphrase handling
# - sudo tar
# - equalize part sizes

files=("$@")
archive="$(readlink -f "$files")"  #take first item of $files
(( ${#files[*]} != 1 )) && archive="$(dirname "$archive")" #set parent dir as archive name if it's more than just 1 item to compress
archive="$(basename "$archive").$(date +d%F)".tar.xz #put archive in current dir, add suffix

tar -cO "${files[@]}" \
  | nice 7z a -an -si -so -txz -m0=lzma2 -mmt=8 -mx=9 -mfb=64 -md=32m \
  | { gpg2 -qcz 0 --passphrase-fd 9 --cipher-algo AES256 --batch 9< \
      <(~/sh/git/new-Passphrase.sh "$archive".txt.gpg)
    } 2> >(sed /"gpg: all values passed to '--default-key' ignored"/d) \
  | \split -d -a 3 -t "\\0" -b 999M - "$archive".gpg.
# remove part suffix (.000) if it resulted in just 1 part
(
  shopt -s nullglob dotglob
  files=("$archive".gpg.[0-9][0-9][0-9])
  (( ${#files[*]} == 1 )) && mv "$archive".gpg{.000,}
)
