#!/bin/bash
cd ~celmor
PWD=~celmor
HOME=~celmor
BackupDS=Data/Backup/LinuxBackupHome
BackupDir=/Data/Backup/Linux/currentHome/
# zfs filesystem properties upon creation:
# zfs create -o atime=on -o acltype=posixacl -o compression=zle -o casesensitivity=sensitive -o sharenfs=off -o sharesmb=off -o mountpoint=/Data/Backup/Linux/currentHome/ Data/Backup/LinuxBackupHome

date=`date +d%F-%0H-%0M`
rsync -ahxHAX --partial --info=progress2 --exclude={".local/share/Steam",".wine/drive_c",".thunderbird/Profiles",".cache",".gem",".tor-browser","Downloads"} --delete-excluded --delete ./ $BackupDir
sudo zfs snapshot $BackupDS@$date && echo "$BackupDS@$date created"
