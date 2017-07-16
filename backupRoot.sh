#!/bin/bash
[ $EUID == 0 ] || { echo "This script must be run as root"; exit 0; }
date="$(date +d%F-%0H-%0M)"
BackupDir="/Data/Backup/Linux/currentRoot"
BackupMount="$(df -P "$BackupDir" | awk 'END { print $NF }')"
[ "$1" == "--zfs" ] && BackupDS="$(df -P "$BackupDir" | awk 'END { print $1 }')"
exclude="/{dev,proc,sys,tmp,run,mnt,media,lost+found,Data,home,usr/share/locale,var,srv,root,$BackupMount}/\*"

rsync -ahxHAX --checksum --info=progress2 --delete --exclude="$exclude" --delete-excluded --delete / "$BackupDir"/ && \
[ "$1" == "--zfs" ] && sudo zfs snapshot "$BackupDS"@"$date" && echo "$BackupDS@$date created"
