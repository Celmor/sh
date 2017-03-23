#!/bin/bash
#author:    celmor
#version:   0.1.1
#version:   0.1.2   accept stdin via '-' as 2nd arg
#version:   0.1.2   allow specification of just 1 arg which let's it automatically read from stdin, restructuring of arg test and reading from input
#todo:
#further arguments as exceptions for dir
#rename 000 if only it as just 1 part exists
#use gpg's --passphrase-fd instead of file

set -o pipefail
#shopt -s extglob
shopt -s nullglob;
# gpg --passphrase-fd 0
#trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG

_help(){
cat << EOF >&2
Usage: $0 [options] ARCHIVE [INPUT]
"input" may be '-' to read from stdin
Archives input via 7z (LZMA2), encrypts it via GnuPG while creating parts
Options:
    -v  Be verbose
        -> uses pv to monitor throughput
    -t  Only test ARCHIVE
        -> expects no input
    -q  Don't test archive after creation
Parameters:
    ARCHIVE
        without .tar.xz.XXX or .xz.XXX suffix
    INPUT
        can be a folder or a file (wildcards aren't supported) or -, if omitted and -t is not set, input is read from stdin
EOF
#[ -v pid ] && kill -s SIGKILL $pid
exit 1
}

_distributeAffinity(){
    i=0; n=8
    pidstat -thu -G "$1" 1 1 | tail -n +5 | sort -nrk 8,8 | awk '{ print $4 }' | while read pid ; do
    taskset -cp $((i % n)) $pid; (( i++ )); done >/dev/null
}


#echo -e "#!/bin/bash\n$distributeAffinity" > /tmp/distributeAffinity.sh
#chmod +x /tmp/distributeAffinity.sh

while getopts "vtq" opt; do
  case $opt in
    v)
      verbose="pv -Warbrt"
      ;;
    t)
      [ -v notest ] && echo "Error: -t -q can't be used together" >&2 && exit 1
      test="test"
      ;;
    q)
      [ -v test ] && echo "Error: -t -q can't be used together" >&2 && exit 1
      notest="notest"
      ;;
    d)
      trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG
      ;;
    f)
      distributeAffinity="_distributeAffinity 7z"
      ;;
    \?)
      _help
      ;;
  esac
done
shift $((OPTIND-1))

# preparation
#taskset -p ff $$ >/dev/null
#sudo -v || exit 1
#sudo bash -c "sleep 1s; rm \"$pass\"" & pid=$!; kill -s SIGSTOP $pid

# check arguments
case $# in
    1) archive="$1" input=-
       ;;
    2) archive="$1"
       input="$2"
       #append .tar suffix if input is a dir (because tar will be used)
       if [ -d "$input" ]; then archive="${archive%.tar}.tar"; fi
       ;;
    # none or too many arguments are given -> print help and exit
    *) _help
       ;;
esac
user=$(whoami)
pass=$(sudo mktemp /tmp/pass.XXX) && sudo chmod 600 "$pass"
# 7z options:
threads=10
compressratio=9
# GPG options: Var_fd='9'

# archive phase
if [ ! -v test ]; then

    # test archive doesn't already exists, then prepare
    [ ! -f "$archive".md5 ] \
    && openssl rand -base64 63 | tr -d '\n' | sudo tee "$pass" \
    | gpg2 -qe --default-key "$user" > "$archive".xz.gpg || _help
_input() {
        # In case of failure either cat or tar will print sensible
        # diagnostic message and produce no output to stdout.
        # It is safe to rely on these diagnostics.
        if [ -f "$input" ] || [ "$input" = "-" ]; then
        cat -- "$input"
        elif [ -d "$input" ]; then
        tar cO --warning=no-file-ignored -C "$(dirname "$input")" -- "$(basename "$input")"
        fi
    }
    _input \
    | tee >(md5sum | awk '{print $1}' | tr -d '\n' > "$archive".md5) \
    | { {
        sleep 5s && ${distributeAffinity:-":"}; } &
        7z a -an -si -so -txz -m0=lzma2 -mmt="$threads" -mx="$compressratio" -mfb=64 -md=32m; } \
    | sudo gpg2 -qc --no-permission-warning --cipher-algo AES256 --batch --passphrase-file "$pass" -z 0 \
    | ${verbose:-"tee"} \
    | split -d -a 3 -t '\0' -b 999M - "$archive".xz. \
    && if [ -v notest ] || [ -v verbose ]; then echo "Archive created."; fi \
    || { echo "Error: failed creating the archive..." >&2; exit 1; }
fi
if [ ! -v notest ]; then
    [ -f "$archive".md5 ] || _help
    sudo -v || exit 1
    gpg2 -qd "$archive".xz.gpg | tr -d '\n' | sudo tee "$pass" >/dev/null \
    && if [ -v test ] || [ -v verbose ]; then echo "Testing archive..."; fi \
    && cat "$archive".xz.[0-9][0-9][0-9] \
    | sudo gpg2 -qd --no-permission-warning --batch --passphrase-file "$pass" \
    | 7z e -an -si -so -txz \
    | ${verbose:-"cat"} \
    | md5sum \
    | { read md5; [[ "$md5" == "$(cat "$archive".md5 2>/dev/null)  -" ]] \
    && if [ -v test ] || [ -v verbose ]; then echo "Archive verified!"; fi; } \
    || { echo "Error: Verification failed (checksum doesn't match)" >&2; exit 1; }
fi
[ -v test ] && echo "Deleting temporary pass-file..."; sudo rm "$pass" #kill -s SIGCONT $pid
