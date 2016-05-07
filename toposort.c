/*
 * COMP20007 Design of Algorithms
 * Semester 1 2016
 *
 * Clement Poh (cpoh@unimelb.edu.au)
 *
 * This module provides all the topological sorting functionality.
 *
*/
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#include "toposort.h"

static const char *cycle_err = "Error: cycle detected\n";

/* Recursive DFS call */
static void dfs_visit(List *sorted, bool *temp, bool *perm, Vertex vertex);

/* Returns the list of source vertices in graph */
static List source_vertices(Graph graph);

/* Checks whether there are any edges left in graph */
static bool any_edges(Graph graph);

/* Recursive call of verify */
static bool verify_visit(bool *visits, List vertices);

/* Returns true if all incoming vertices have been visited already */
static bool visited(bool *visits, List in);

/* Marks vertex as visited in visits */
static bool *visit(bool *visits, Vertex vertex);

/* Returns a list of topologically sorted vertices using the DFS method */
List dfs_sort(Graph graph) {
    List sorted = NULL;

    /* Used to store whether a vertex has been temporarily visited */
    bool *temp = calloc(graph->order, sizeof(*temp));
    /* Used to store whether a vertex has been permanently visited */
    bool *perm = calloc(graph->order, sizeof(*perm));

    assert(temp);
    assert(perm);

    for (int i = 0; i < graph->order; i++) {
        dfs_visit(&sorted, temp, perm, graph->vertices + i);
    }

    free(temp);
    free(perm);
    return sorted;
}

/* Recursive DFS call */
static void dfs_visit(List *sorted, bool *temp, bool *perm, Vertex vertex) {
    List edge = vertex->out;

    if (temp[vertex->id]) {
        fprintf(stderr, cycle_err);
        exit(EXIT_FAILURE);

    } else if (!perm[vertex->id]) {
        temp[vertex->id] = true;

        while(edge) {
            dfs_visit(sorted, temp, perm, edge->data);
            edge = edge->next;
        }

        perm[vertex->id] = true;
        temp[vertex->id] = false;

        prepend(sorted, vertex);
    }
}

/* Returns a list of topologically sorted vertices using the Kahn method */
List kahn_sort(Graph graph) {
    List sorted = NULL;
    Vertex orig = NULL, dest = NULL;
    List sources = source_vertices(graph);

    while (sources) {
        orig = pop(&sources);
        insert(orig, &sorted);

        dest = pop(&orig->out);
        while (dest) {
            del(ptr_eq, orig, &dest->in);

            if (!dest->in)
                prepend(&sources, dest);

            dest = pop(&orig->out);
        }
    }

    if (any_edges(graph)) {
        fprintf(stderr, cycle_err);
        exit(EXIT_FAILURE);
    }

    return sorted;
}

/* Returns the list of source vertices in g */
static List source_vertices(Graph graph) {
    List sources = NULL;

    for (int i = 0; i < graph->order; i++) {
        if (!graph->vertices[i].in)
            prepend(&sources, graph->vertices + i);
    }
    return sources;
}

/* Checks whether there are any edges left in graph */
static bool any_edges(Graph graph) {
    for (int i = 0; i < graph->order; i++) {
        if (graph->vertices[i].in)
            return true;
    }

    return false;
}

/* Check whether vertices is a toposort of graph */
bool verify(Graph graph, List vertices) {
    /* Used to store whether a vertex has been visited */
    bool *visits = calloc(graph->order, sizeof(*visits));
    assert(visits);

    return verify_visit(visits, vertices);
}

/* Recursive call of verify */
static bool verify_visit(bool *visits, List vertices) {
    /* If vertices is NULL, it's a valid toposort */
    return !vertices
        ? true
        /* The sequence is invalid if we haven't visited an incoming vertex */
        : !visited(visits, ((Vertex)vertices->data)->in)
            ? false
            /* Mark the current vertex as visited and process next one */
            : verify_visit(visit(visits, vertices->data), vertices->next);
}


/* Returns true if all the incoming vertices have been visited already */
static bool visited(bool *visits, List in) {
    return !in
        ? true
        : !visits[((Vertex)in->data)->id]
            ? false
            : visited(visits, in->next);
}

/* Marks vertex as visited in visits */
static bool *visit(bool *visits, Vertex vertex) {
    visits[vertex->id] = true;
    return visits;
}
