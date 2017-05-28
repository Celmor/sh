#!/bin/bash
i=0; n=6; offset=2
pidstat -thu -G "$1" 1 1 | tail -n +5 | sort -nrk 8,8 | awk '{ print $4 }' | while read pid ; do
taskset -cp $((i % n + 2)) $pid; (( i++ )); done >/dev/null
