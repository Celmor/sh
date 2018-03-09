#!/bin/bash

set -e
[ $# -gt 0 ] && echo "usage $0" && exit 1

for flash in "/dev/disk/by-id/usb-Samsung_Type-C_0374917020008616-0:0-part1" \
             "/dev/disk/by-id/usb-Kingston_DataTraveler_3.0_D850E64D1AD1BEC069BD0D36-0:0-part1"; do
    printf "Trying to mount: %s\\n" "$(basename "$flash")"
    if sudo mount "$flash" /media/flash; then
        break
    else
        true
    fi
done
function mount-Zpool {
    zpool="$1"
    mountpoint="$2"
    storage="$3"
    service="$4"

    printf "mount-Zpool: Preparing mountpoint: %s...\\n" "$storage" >&2
    if [ -d "$mountpoint" ]; then
        if sudo find /"$zpool"/* -type d -empty -delete; then
            printf "Cleared empty dirs on mountpoint: /%s/.\\n" "$zpool"  >&2
        else
            true
        fi
    fi
    printf "mount-Zpool: Preparing storage: %s...\\n" "$storage" >&2
    if [ -f "$storage" ]; then
        parent="$(dirname "$storage")"
    elif [ -b "$storage" ]; then
        parent="/dev/mapper"
        sudo cryptsetup luksOpen "$storage" "$zpool"
    fi

    if sudo zpool import -d "$parent" "$zpool"; then
        printf "mount-Zpool: import successful: %s\\n" "$zpool" >&2
    else
        printf "mount-Zpool: import failed: %s\\n" "$zpool" >&2
        exit 1
    fi
    printf "mount-Zpool: starting service: %s..." "$zpool" >&2
    [ "$service" = "" ] || sudo systemctl start "$service"
}
mount-Zpool "DataRecover" "/DataRecover" "/dev/disk/by-id/usb-WD_My_Book_25EE_575838314436354153553250-0:0-part2" "nfs-server"
mount-Zpool "zpool-docker" "/docker" "docker"

trap : INT
for encfs in ~/{secure,new/bill,Downloads/jdownloader}; do
    if mountpoint -q ~/"$encfs"; then
        printf "mount: already mounted: %s\\n" "$encfs" >&2
        continue
    else
        printf "mount: opening: %s...\\n" "$encfs" >&2
        if encfs "$(dirname "$encfs")"/."$(basename "$encfs")" "$encfs"; then
            printf "mount: opened: %s...\\n" "$encfs" >&2
        else
            printf "mount: open failed: %s...\\n" "$encfs" >&2
        fi

    fi
done
trap - INT