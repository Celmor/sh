#!/bin/bash
# first parameter specifies subversion, i.e. 10 for 4.10.*
[[ "$1" =~ ^[0-9]+$ ]] && subversion=$1 || subversion=10
file="${HOME}/new/log/pacman.$(date +d%F | tr -d '\n').mkinitcpio-linux4${subversion}.log"
sudo mv /etc/modprobe.d/vfio.conf{.save,}
sudo mkinitcpio --kernel $(foo=$(file /boot/vmlinuz-4.${subversion}-x86_64); bar="${foo##* version }"; baz="${bar% *}"; echo "$baz") -c /etc/mkinitcpio-passthrough.conf -g "/boot/initramfs-passthrough-4.${subversion}-x86_64.img" | tee $file && \
sudo mv /etc/modprobe.d/vfio.conf{,.save}
