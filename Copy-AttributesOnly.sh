#!/bin/bash
# alternative for `cp --attributes-only`
# https://askubuntu.com/questions/56792/how-to-copy-only-file-attributes-metadata-without-actual-content-of-the-file#56810
chmod --reference="$1" "$2"
chown --reference="$1" "$2"
touch --reference="$1" "$2"
