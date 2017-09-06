#!/bin/bash
# alternative for `cp --attributes-only`
# https://askubuntu.com/questions/56792/how-to-copy-only-file-attributes-metadata-without-actual-content-of-the-file#56810
if [ $# -ne 2 ]; then
	echo "Usage: $0 REFERENCE TARGET"
	exit 1
fi
chmod --reference="$1" "$2"
chown --reference="$1" "$2"
touch --reference="$1" "$2"
