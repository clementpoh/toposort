/*
 * COMP20007 Design of Algorithms
 * Semester 1 2016
 *
 * Clement Poh (cpoh@unimelb.edu.au)
 *
 * This module provides all the IO functionality related to graphs.
 *
*/
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "graphio.h"

#define MAX_LINE_LEN 256

/* Loads vertex labels and id numbers from file */
static void load_vertex_labels(FILE *file, Graph graph);

/* Loads the edges into the graph from file */
static void load_edges(FILE *file, Graph graph);

/* Prints the graph as a DOT file to output */
static void pgraph(char *output, Graph graph, bool rev);

/* Returns a copy of src */
static char *safe_copy(char *src);

/* Returns a pointer to file */
static FILE *safe_open(char *file, const char *mode);

/* Loads the graph from input */
Graph load_graph(char *input) {
    int order = 0;
    Graph graph = NULL;

    FILE *file = safe_open(input, "r");

    fscanf(file, "%d\n", &order);

    graph = new_graph(order);
    load_vertex_labels(file, graph);
    load_edges(file, graph);

    fclose(file);

    return graph;
}

/* Loads vertex labels and id numbers from file */
static void load_vertex_labels(FILE *file, Graph graph) {
    char label[MAX_LINE_LEN];

    for (int i = 0; i < graph->order; i++) {
        fgets(label, MAX_LINE_LEN, file);
        graph->vertices[i].label = safe_copy(label);
        graph->vertices[i].id = i;
    }
}

/* Loads the edges into the graph from file */
static void load_edges(FILE *file, Graph graph) {
    int v1 = 0 , v2 = 0;

    while (fscanf(file, "%d %d\n", &v1, &v2) == 2) {
        assert(v1 >= 0);
        assert(v2 >= 0);
        assert(v1 < graph->order);
        assert(v2 < graph->order);

        add_edge(graph, v1, v2);
    }
}

void print_graph(char *output, Graph graph) {
    char reverse[MAX_LINE_LEN];

    pgraph(output, graph, false);

    /* Print out a reversed version of the graph */
    sprintf(reverse, "%s.rev", output);
    pgraph(reverse, graph, true);
}

/* Prints the graph */
static void pgraph(char *output, Graph graph, bool rev) {
    FILE *file = safe_open(output, "wb");

    fprintf(file, "digraph {\n");

    for(int i = 0; i < graph->order; i++) {
        fprintf(file, "  %s", graph->vertices[i].label);

        if (graph->vertices[i].out) {
            fprintf(file, " -> {");

            if (rev)
                print_list_rev(print_vertex_label, file, graph->vertices[i].out);
            else
                print_list(print_vertex_label, file, graph->vertices[i].out);

            fprintf(file, "}");
        }
        fprintf(file, "\n");
    }
    fprintf(file, "}\n");

    fclose(file);
}

/* Prints the destination vertex label surrounded by spaces */
void print_vertex_label(FILE *file, void *vertex) {
    if (vertex)
        fprintf(file," %s ", ((Vertex)vertex)->label);
}

/* Prints the id of a vertex then a newline */
void print_vertex_id(FILE *file, void *vertex) {
    if (vertex)
        fprintf(file, "%d\n", ((Vertex)vertex)->id);
}

/* Returns a sequence of vertices read from file */
List load_vertex_sequence(FILE *file, Graph graph) {
    const char *err_duplicate = "Error: duplicate vertex %d %s\n";
    const char *err_order = "Error: graph order %d, loaded %d vertices\n";
    List list = NULL;
    int id;

    while(fscanf(file, "%d\n", &id) == 1) {
        assert(id >= 0);
        assert(id < graph->order);

        if (!insert_if(id_eq, graph->vertices + id, &list)) {
            fprintf(stderr, err_duplicate, id, graph->vertices[id].label);
            exit(EXIT_FAILURE);
        }
    }

    if (len(list) != graph->order) {
        fprintf(stderr, err_order, graph->order, len(list));
        exit(EXIT_FAILURE);
    }

    return list;
}

/* Returns a copy of src */
static char *safe_copy(char *src) {
    /* Remove the newline as required */
    src[strcspn(src, "\n")] = '\0';
    /* Malloc enough space for the null byte */
    char *dest = malloc(sizeof(*dest) * strlen(src) + 1);
    assert(dest);
    return strcpy(dest, src);
}

/* Returns a pointer to file */
static FILE *safe_open(char *filename, const char *mode) {
    const char *err = "Could not open file: %s\n";
    FILE *file = fopen(filename, mode);

    if (file) {
        return file;
    } else {
        fprintf(stderr, err, filename);
        exit(EXIT_FAILURE);
    }
}

