/*
 * COMP20007 Design of Algorithms
 * Semester 1 2016
 *
 * Clement Poh (cpoh@unimelb.edu.au)
 *
 * This provides all the non-IO functionality related to graphs.
 *
*/
#include <stdlib.h>
#include <assert.h>

#include "graph.h"

/* Returns a pointer to a new graph with order vertices */
Graph new_graph(int order) {
    Graph graph = malloc(sizeof(*graph));
    assert(graph);

    graph->order = order;
    graph->size = 0;

    graph->vertices = calloc(order, sizeof(*graph->vertices));
    assert(graph->vertices);

    return graph;
}

/* Returns whether aim and vertex are pointing to the same location */
bool ptr_eq(void *aim, void *vertex) {
    return aim == vertex;
}

/* Returns whether aim and vertex have the same id */
bool id_eq(void *aim, void *vertex) {
    Vertex v1 = aim, v2 = vertex;
    return (!v1 && !v2) ? true : v1->id == v2->id;
}

/* Add the edge from v1 to v2 to graph */
void add_edge(Graph graph, int v1, int v2) {
    graph->size++;
    prepend(&graph->vertices[v1].out, graph->vertices + v2);
    prepend(&graph->vertices[v2].in, graph->vertices + v1);
}

/* Free the memory allocated to graph */
void free_graph(Graph graph) {
    if (graph) {
        for (int i = 0; i < graph->order; i++) {
            free_list(graph->vertices[i].out);
            free_list(graph->vertices[i].in);
            free(graph->vertices[i].label);
        }

        free(graph->vertices);
        free(graph);
    }
}
