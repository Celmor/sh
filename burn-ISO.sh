#!/bin/bash
# For "burning" an ISO to a portable/external drive and backing up space that's to be overwritten
if [ "$1" == "-h" ] || [ "$#" -gt 3 ] || [ "$#" -lt 2 ]; then
	printf "Usage: %s ISO DEVICE [BACKUP_TEMPLATE]\\n" "$0"
	exit 0
fi
iso="$1"
dev="$2"
bak="${3:-"/tmp/${2##*/}.header.dd"}"

if [ ! -e "$bak" ]; then
	echo "INFO: Backing up area that's about to be overwritten..."
	dd bs=16M count=$(($(du "$iso" | awk '{ print $1 }')/16384+1)) if="$dev" of="$bak" status=progress && sync \
	&& {
		echo "INFO: Copying ISO to device..."
		dd bs=16M if="$iso" of="$dev" status=progress && sync
	} \
	|| echo "Error: Failed copying ISO!"
else
	echo "INFO: Found Backup, writing it back to device..."
	dd bs=16M if="$bak" of="$dev" status=progress && sync \
	|| echo "Error: Failed copying backup back to device!"
fi
echo "INFO: done!"
