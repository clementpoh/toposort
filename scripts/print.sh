#!/bin/bash
#
# Clement Poh
#
# Designed to test graph input and output of the assignment
# specified as the first argument to the script.
#
# The script makes the following assumptions:
#   * The assignment in arg1 is already compiled.
#   * Test graphs and their dot files reside in ./test
#   * Graph files end with the .in extension
#   * Dot files end with the .dot extension
#
SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TIMEOUT="$SCRIPTS/timeout.sh"
ISOMORPH="$TIMEOUT -t 1 $SCRIPTS/isomorphic.py"

SHELL="/tmp/shell"
ERRORS="/tmp/error"

TESTS="./test"
EXT=".in"
GRAPHS="$TESTS/*$EXT"

COUNT=0
PASS=0

# Run the submission
if [ -d "$1" ]; then
    USER=$(basename "$1")
    BIN="$1/ass1"
    OUT="$1/out"
    LOGFILE="$OUT/print.txt"

    # Remove any dot files already there
    rm -f $OUT/*.dot

    printf "******************************************\n" > $LOGFILE
    printf "* Part 1: Graph Input and Output\n" >> $LOGFILE
    printf "******************************************\n" >> $LOGFILE

    # Check whether the executable exists
    if [ ! -x $BIN ]; then
        printf "Not found: $BIN\n"
        printf "Not found: ass1\n" >> $LOGFILE
        exit 127
    fi

    for graph in $GRAPHS; do
        BASE=$(basename "$graph" "$EXT")

        # Location of the output dot file
        OUTPUT="$OUT/$BASE.dot"
        # Location of the verification file
        VERIFY="$TESTS/$BASE.dot"

        # Check whether the verification dot file exists
        if [ ! -f "$VERIFY" ]; then
            printf "Verification file not found: $VERIFY\n"
            exit 66
        fi

        # Braces are for errors that originate from the shell, like segfaults
        { "$TIMEOUT" "$BIN" -p "$OUTPUT" "$graph" &> $ERRORS; } &> $SHELL

        EXIT=$?
        case "$EXIT" in
            0)  # Check whether graphs are isomorphic
                if diff -w "$OUTPUT" "$VERIFY" &> /dev/null; then
                    MSG="PASS: diff -w $OUTPUT $VERIFY\n"
                    PASS=$((PASS + 1))
                elif diff -w "$OUTPUT" "$VERIFY.rev" &> /dev/null; then
                    MSG="PASS: diff -w $OUTPUT $VERIFY.rev\n"
                    PASS=$((PASS + 1))
                elif { $ISOMORPH "$OUTPUT" "$VERIFY" 2>> $SHELL; } 2> /dev/null; then
                    # Python script to verify, also reports formatting issues
                    MSG="PASS: scripts/isomorphic.py $OUTPUT $VERIFY\n"
                    PASS=$((PASS + 1))
                else
                    MSG="FAIL: diff -w $OUTPUT $VERIFY\n"
                fi ;;
            1)  # Program exited with EXIT_FAILURE
                MSG="$EXIT: $BIN -p $OUTPUT $graph\n";;
            3)  # Seems to indicate failed assertion in MinGW
                MSG="$EXIT: $BIN abort\n";;
            5)  # Seems to indicate segmentation fault in MinGW
                MSG="$EXIT: $BIN segmentation fault\n";;
            126) # Command is not executable
                MSG="$EXIT: $BIN not executable\n";;
            127) # Command is not found
                MSG="$EXIT: $BIN not found\n";;
            255) # Exit called incorrectly
                MSG="$EXIT: $BIN exit called incorrectly\n";;
            *)  if [ $EXIT -lt 128 ]; then
                    MSG="$EXIT: $BIN -p $OUTPUT $graph\n"
                else
                    # Program killed by signal
                    SIG=$(kill -l $EXIT)

                    MSG="$SIG: $BIN -p $OUTPUT $graph\n"
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
    printf "\n$PASS/$COUNT successful\n" >> $LOGFILE
fi

# The $((expr)) works like in C, so negate it to get the correct exit status
exit $((! ($PASS == $COUNT)))
