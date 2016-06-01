#!/bin/sh
#
# Clement Poh
#
# Generates a series of random Graphs and DAGs
#
TESTS=${1:-"../test"}
BIN=${2:-"../soln/graphgen"}
EXT=${3:-".in"}
SEED=${4:-1013}

printf "Generating graphs in $TESTS with seed $SEED\n"

printf "Generating graphs\n"
edge=035
for order in 0010 0100 1000; do
    $BIN $order $edge $SEED true > "$TESTS/graph.$order-$edge$EXT"
done

printf "Generating DAGs\n"
for order in 0010 0100 1000; do
    for edge in 015 045; do
        $BIN $order $edge $SEED > "$TESTS/dag.$order-$edge$EXT"
    done
done

printf "Generating empty DAG\n"
order=1000
edge=000
$BIN $order $edge $SEED > "$TESTS/dag.$order-$edge$EXT"

printf "Generating complete DAG\n"
order=1000
edge=100
$BIN $order $edge $SEED > "$TESTS/dag.$order-$edge$EXT"

printf "Generating complete graph\n"
order=1000
edge=100
$BIN $order $edge $SEED true > "$TESTS/graph.$order-$edge$EXT"

# printf "Generating large DAG\n"
# order=20000
# edge=055
# $BIN $order $edge $SEED true > "$TESTS/dag.$order-$edge$EXT"
