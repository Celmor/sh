# to source in bashrc
pool=( Data DataBackup DataNew )
getPool(){ [ $# -ne 1 ] && exit 1; [ "$(dirname "$1")" = "/" ] && printf '%s\n' "$1" && exit 0; printf '%s\n' "$(getPool "$(dirname "$1")")"; }
comparePool(){ root="$(getPool $1)"; root=${root///}; for i in ${pool[@]}; do [ "$root" = "$i" ] && continue; printf '%s\n' "comparing "$root" -> $i:"; sudo rsync -axHAXS --delete -i --dry-run "$1/" /"$i${1//"/$root"}"/; done; }
syncPool(){ root="$(getPool $1)"; root=${root///}; for i in ${pool[@]}; do [ "$root" = "$i" ] && continue; printf '%s\n' "comparing "$root" -> $i:"; sudo rsync -axHAXS -i --delete "$1/" /"$i${1//"/$root"}"/; done; }
