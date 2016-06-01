#!/bin/bash
#
# Clement Poh
#
# Verifies that the verify function works correctly
#
SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TIMEOUT="$SCRIPTS/timeout.sh"

SHELL="/tmp/shell"
ERRORS="/tmp/error"

TESTS="./test"
SOLN="./soln/soln"
EXT=".in"
GRAPHS="$TESTS/dag.*-*$EXT"

COUNT=0
PASS=0

# Run the submission
if [ -d "$1" ]; then
    USER=$(basename "$1")
    BIN="$1/ass1"
    OUT="$1/out"
    LOGFILE="$OUT/verify.txt"

    printf "******************************************\n" > $LOGFILE
    printf "* Part 4: Verification\n" >> $LOGFILE
    printf "******************************************\n" >> $LOGFILE

    # Check whether the executable exists
    if [ ! -x $BIN ]; then
        printf "Not found: $BIN\n"
        printf "Not found: ass1\n" >> $LOGFILE
        exit 127
    fi

    for graph in $GRAPHS; do
        BASE=$(basename "$graph" "$EXT")
        ORDER=$(expr match $BASE ".*\.\(.*\)-")

        DFS="$TESTS/dag.$ORDER-*.dfs"
        # KAHN="$TESTS/dag.$ORDER-*.kahn"

        for INPUT in $DFS; do

            # Braces are for errors that originate from the shell
            { "$TIMEOUT" "$BIN" -v "$graph" < $INPUT &> $ERRORS; } &> $SHELL

            EXIT=$?
            case "$EXIT" in
                0)  if $SOLN -v "$graph" < "$INPUT"; then
                        MSG="PASS: $BIN -v $graph < $INPUT\n"
                        PASS=$((PASS + 1))
                    else
                        MSG="FAIL: $BIN -v $graph < $INPUT\n"
                    fi ;;
                1)  if ! $SOLN -v "$graph" < "$INPUT"; then
                        MSG="PASS: $BIN -v $graph < $INPUT\n"
                        PASS=$((PASS + 1))
                    else
                        MSG="EXIT: $BIN -v $graph < $INPUT\n"
                    fi ;;
                3)  # Seems to indicate failed assertion in MinGW
                    MSG="$EXIT: $BIN aborted\n";;
                5)  # Seems to indicate segmentation fault in MinGW
                    MSG="$EXIT: $BIN segmentation fault\n";;
                126) # Command is not executable
                    MSG="$EXIT: $BIN not executable\n";;
                127) # Command is not found
                    MSG="$EXIT: $BIN not found\n";;
                255) # Exit called incorrectly
                    MSG="$EXIT: $BIN exit called incorrectly\n";;
                *)  if [ $EXIT -lt 128 ]; then
                        MSG="$EXIT: $BIN -v $graph < $INPUT\n"
                    else
                        # Program killed by signal
                        SIG=$(kill -l $EXIT)

                        MSG="$SIG: $BIN -v $graph < $INPUT\n"
                        ERR="$SIG $graph"
                    fi
            esac

            printf "$MSG"
            printf "$MSG" >> $LOGFILE

            # Append shell errors if they exist
            if [ -s $SHELL ]; then
                printf "    Shell messages:\n" >> $LOGFILE
                nl $SHELL >> $LOGFILE
            fi

            # Append program errors if they exist
            if [ -s $ERRORS ]; then
                printf "    Program output:\n" >> $LOGFILE
                nl $ERRORS >> $LOGFILE
            fi

            COUNT=$((COUNT + 1))
        done
    done
    printf "\n$PASS/$COUNT successful\n" >> $LOGFILE
fi

# The $((expr)) works like in C, so negate it to get the correct exit status
exit $((! ($PASS == $COUNT)))
