#!/bin/bash
# calls zfs diff on filesystem with latest diff
# mounts (readonly) if necessary
for i in "$@"; do
	snapshot="$(zfs list -t snapshot -o name -s creation -d 1 -r "$i" | tail -1)
	if [ "$snapshot" = "no datasets available" ]; then
		printf '%s\n' "error: \"$i\" has no snapshots";
	fi
	unset canmount
	if [ "$(zfs get -Ho value canmount "$i")" = "off" ]; then
		canmount="off"
		unset readonly
		if [ "$(zfs get -Ho value readonly "$i")" = "no" ]; then
			readonly="no"
			zfs set readonly=on "$i"
		fi
		zfs set canmount=on "$i"
	fi
	zfs mount "$i" 2>&1 | grep -v already mounted >&2
	zfs diff "$snapshot" "$i"
	[ "$canmount" = "off" ] && zfs set canmount=off "$1" && \
	[ "$readonly" = "no" ] && zfs set canmount=no "$1"
done
