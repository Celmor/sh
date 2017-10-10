#!/bin/bash
# Menu to easly select an item from a (small) selection
# selection/array is parameter list, selected item is exit code
fail(){ exit -1; }
trap fail INT TERM
[ $# -eq 0 ] && options=( "option 1" "option 2" "option 3" "option 4" "option 5" ) \
|| [ $# -eq 1 ] && echo "$1" \
|| options=($@)
index=0
message=""
while :; do
	clear
        for (( i=0; i<${#options[@]}; i++ )); do
                [ $i = $index ] && printf '\n> ' || printf '\n  '
                printf '%s' "${options[$i]}"
        done
        printf '\n%s' "$message" && unset message
        printf '\n%s' "w for up, s for down, enter to confirm"
	read -rsn1 key
        case "$key" in
                "w")
                        ((index--)); [ $index -lt 0 ] && index=0;;
			
                "s")
			((index++)); [ $index -ge ${#options[@]} ] && index=$(( ${#options[@]} - 1 ));;
                "")
                        clear && exit $index 
			break
			;;
		*) 
			message="wrong key"
			;;
        esac
done
        

