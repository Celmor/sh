#!/bin/bash
[ $# -ne 2 ] && printf "USAGE: %s FILE TARGET\\n" "$0"
file="$1"
target="$2"
[ "$target" = *"EOF"* ] && printf "TARGET containing \"EOF\" isn't supported\\n" "$0"
cat <<EOF > "$file"
[Desktop Entry]
Icon=folder
Type=Link
URL=file://$target
EOF
