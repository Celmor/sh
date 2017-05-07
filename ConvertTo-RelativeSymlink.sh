#!/bin/bash
# verion:    1.0
# Desc:      Rewrite Symbolic Link with target to an absolate path
#            to a target with relative path (i.e. relative symlink)
# Parameter: 1 Smybolic link as first argument, further arguments ignored
link="$1"

# source of functions: http://paste.lisp.org/display/346076#1
# by pjb on irc.freenode.net#bash
function enoughNamestring(){
    local path="$1"
    local base="$2"
    local -a apath
    local -a abase
    local minlen
    local i
    # If path is an absolute pathname,
    # then it is reduced to a pathname relative to base
    # else it's returned as is.
    case "$path" in
        (/*)
            IFS=/ read -ra apath <<<"$path"
            IFS=/ read -ra abase <<<"$base"
            if [[ ${#apath[@]} -lt ${#abase[@]} ]] ; then
                minlen=${#apath[@]}
            else
                minlen=${#abase[@]}
            fi
            i=0
            while [[ $i -lt $minlen && "${apath[$i]}" = "${abase[$i]}" ]] ; do
                i=$((i+1))
            done
            result="$(repeat ../ $((${#abase[@]}-i)))$(eval join / "${apath[@]:$i}")"
            if [[ -z "$result" ]] ; then
                echo "./"
            else
                echo "$result"
            fi
            ;;
        (*)
            echo "$path"
            ;;
    esac
}
function join(){
    local sep="$1";shift
    local cur=""
    for arg ; do
        printf "%s%s" "$cur" "$arg"
        cur="$sep"
    done
}

function repeat(){
    local string="$1"
    local count="$2"
    while [[ 0 -lt $count ]] ; do
        printf "%s" "$string"
        count=$((count-1))
    done
}

# caching or relpath and unlinking required on some systems
# (i.e. arch) as ln -f may be unable to overwrite symlink
relpath="$(enoughNamestring "$(readlink "$link")" "$(dirname "$link")")"
unlink "$link"
ln -sf "$relpath" "$link"
