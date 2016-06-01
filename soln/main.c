/*
 * COMP20007 Design of Algorithms
 * Semester 1 2016
 * Assignment 1 driver
 *
 * Clement Poh (cpoh@unimelb.edu.au)
 *
 * This module processes and runs the program.
 *
*/
#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>
#include <time.h>

#include "graph.h"
#include "graphio.h"
#include "toposort.h"

#define MAX_LINE_LEN 256

typedef enum {
    NONE    = 0,
    DFS     = 1,
    KAHN    = 2,
} sort_method;

/* Struct to store the configuration options from the command line */
typedef struct {
    int sort;
    char *method;
    bool verify;
    bool print;
    bool free;
    char *output;
    char *exe;
    char *input;
} Options;

/* Print usage message and exit */
static void usage_exit(char *exe);

/* Load the the command line options into opts */
static Options load_options(int argc, char *argv[]);

/* Print usage message and exit */
static void usage_exit(char *exe) {
    fprintf(stderr, "Usage: %s (-p output | -m method | -v) <input>\n", exe);
    fprintf(stderr, "-p     print input graph to output\n");
    fprintf(stderr, "-m     topological sort method\n");
    fprintf(stderr, "-v     verify topologically sorted list\n");
    exit(EXIT_FAILURE);
}

/* Load the the command line options into opts */
static Options load_options(int argc, char *argv[]) {
    /* Uses the built-in C standard library function getopt to process the
     * command line arguments. */
    extern char *optarg;
    extern int optind;
    int c;
    Options opts = {
        .sort   = NONE,
        .method = NULL,
        .verify = false,
        .print  = false,
        .free   = false,
        .output = NULL,
        .exe    = argv[0],
        .input  = NULL,
    };

    while ((c = getopt(argc, argv, "m:ap:vf")) != -1) {
        switch (c) {
        case 'm':
            opts.sort = atoi(optarg);
            switch (opts.sort) {
                case DFS : opts.method = "DFS" ; break;
                case KAHN: opts.method = "Kahn"; break;
                default:
                    fprintf(stderr, "Unrecognised sort method\n");
                    usage_exit(opts.exe);
            }
            break;
        case 'p':
            opts.print = true;
            opts.output = optarg;
            break;
        case 'v': opts.verify = true;  break;
        case 'f': opts.free = true;  break;
        case '?':
        default: usage_exit(opts.exe);
        }
    }

    /* Check that one of -p, -m, -f or -v is specified. */
    if (!(opts.print || opts.sort || opts.verify || opts.free)) {
        fprintf(stderr, "One of -p, -v or -m must be specified\n");
        usage_exit(opts.exe);
    }

    /* Check that only one of -m or -v is specified. */
    if (opts.sort && opts.verify) {
        fprintf(stderr, "Only one of -v or -m may be specified\n");
        usage_exit(opts.exe);
    }

    /* Check that input is specified. */
    if (optind + 1 > argc) {
        fprintf(stderr, "Missing input file\n");
        usage_exit(opts.exe);
    } else {
        opts.input = argv[optind];
    }

    return opts;
}

/* Main driver for the program */
int main(int argc, char *argv[]) {
    List sorted = NULL;
    Options opts = load_options(argc, argv);
    Graph graph = load_graph(opts.input);

    if (opts.print)
        print_graph(opts.output, graph);

    switch (opts.sort) {
        case DFS : sorted =  dfs_sort(graph); break;
        case KAHN: sorted = kahn_sort(graph); break;
    }

    if (sorted) {
        print_list(print_vertex_id, stdout, sorted);
    }

    if (opts.verify) {
        sorted = load_vertex_sequence(stdin, graph);

        exit(verify(graph, sorted) ? EXIT_SUCCESS : EXIT_FAILURE);
    }

    if (opts.free) {
        free_list(sorted);
        free_graph(graph);
    }

    exit(EXIT_SUCCESS);
}

