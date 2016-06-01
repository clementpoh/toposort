#!/bin/bash
#
# Clement Poh
#
# Designed to test the topological orderings
#
# The script makes the following assumptions:
#   * The assignment in arg1 is already compiled.
#   * Test graphs and their dfs files reside in ./test
#   * Graph files end with the .in extension
#
SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TIMEOUT="$SCRIPTS/timeout.sh"

SHELL="/tmp/shell"
ERRORS="/tmp/error"

TESTS="./test"
SOLN="./soln/soln"
EXT=".in"
GRAPHS="$TESTS/*$EXT"

TITLE="Part 2: DFS"
OPT="-m 1"
LOGNAME="dfs.txt"
FMT=".dfs"

while getopts ":m:b:" opt; do
    case "$opt" in
        m) case $OPTARG in
                1) ;;
                2)  TITLE="Part 3: Kahn's"
                    OPT="-m 2"
                    LOGNAME="kahn.txt"
                    FMT=".kahn"
                    TIMEOUT="$SCRIPTS/timeout.sh -t 20"
                    ;;
                *) printf "Unrecognized option\n"; exit 1
            esac;;
        b) SOLN="$OPTARG" ;;
        *) printf "Unrecognized option\n"; exit 1
    esac
done
shift $((OPTIND - 1))

COUNT=0
PASS=0

# Run the submission
if [ -d "$1" ]; then
    USER=$(basename "$1")
    BIN="$1/ass1"
    OUT="$1/out"
    LOGFILE="$OUT/$LOGNAME"

    # Remove any dfs files already there
    rm -f $OUT/*$FMT

    printf "******************************************\n" > $LOGFILE
    printf "* $TITLE Algorithm for Toposort\n" >> $LOGFILE
    printf "******************************************\n" >> $LOGFILE

    # Check whether the executable exists
    if [ ! -x $BIN ]; then
        printf "Not found: $BIN\n"
        printf "Not found: ass1\n" >> $LOGFILE
        exit 127
    fi

    for graph in $GRAPHS; do
        BASE=$(basename "$graph" "$EXT")

        # Location of the output dfs file
        OUTPUT="$OUT/$BASE$FMT"

        # Braces are for errors that originate from the shell, like segfaults
        { $TIMEOUT "$BIN" $OPT "$graph" > $OUTPUT 2> $ERRORS; } &> $SHELL

        EXIT=$?
        case "$EXIT" in
            0)  # Verify the output sequence
                if { $SOLN -v $graph < $OUTPUT 2>> $ERRORS; } >> $SHELL 2>&1; then
                    MSG="PASS: $SOLN -v $graph < $OUTPUT\n"
                    PASS=$((PASS + 1))
                else
                    MSG="FAIL: $SOLN -v $graph < $OUTPUT\n"
                fi ;;
            1)  # Program exited with EXIT_FAILURE
                if [[ $BASE =~ ^graph.*.$ ]]; then
                    MSG="PASS: $BIN $OPT $graph > $OUTPUT\n"
                    PASS=$((PASS + 1))
                else
                    MSG="EXIT: $BIN $OPT $graph > $OUTPUT\n"
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
                    MSG="$EXIT: $BIN $OPT $graph > $OUTPUT \n"
                else
                    # Program killed by signal
                    SIG=$(kill -l $EXIT)

                    MSG="$SIG: $BIN $OPT $graph > $OUTPUT\n"
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

