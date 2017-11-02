#!/bin/bash
[ $# -ne 1 ] && { printf "%s\n" "Usage: $0 PACKAGE"; exit 1; }
grpnfo=$(pacman -Sg --color=always "$1") \
|| pkgnfo=$(pacman -Si --color=always "$1") || exit 2
log="$HOME/new/log/pacman.$(date +d%F).$1.color.log"
printf "%s\n" "> $log"
printf "%s\n" "${grpnfo}${pkgnfo}" | tee -a "$log"
printf "%s\n" "$ sudo pacman -S $1" | tee -a "$log"
script -a -c "sudo pacman -Sy --color=always $1" | tee -a "$log"
