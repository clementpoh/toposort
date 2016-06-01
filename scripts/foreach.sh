#!/bin/bash
#
# Clement Poh
#
# Utility script to run the sh script specified in $1 on all the folders in $2

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default timeout is two minutes
TIMEOUT=120
COUNT=0
PASS=0
FAIL=0

# The directory is the last positional argument
LEN="${#@}"
DIR="${@:$LEN}/*"
BIN="${@:1:$(($LEN - 1))}"

for dir in $DIR; do
    if [ -d "$dir" ]; then
        COUNT=$((COUNT + 1))
        $SCRIPTDIR/timeout.sh -t $TIMEOUT $BIN "$dir"

        case "$?" in
            0) PASS=$((PASS + 1)) ;;
            *) FAIL=$((FAIL + 1))
        esac
    fi
done

printf "$PASS/$COUNT successful\n"
