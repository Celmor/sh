#!/bin/bash
# edit PGP RSA encrypted plain text file in-place
# requires 'vipe' (moreutils) and vim
for file in "$@"; do
        [ -f "$file" ] \
        && gpg2 --use-embedded-filename -qd "$file" \
        | vipe \
        | gpg2 --use-embedded-filename -o "$file" --batch --yes -qe \
        || printf '%s\n' "error: $file does not exist"
done
