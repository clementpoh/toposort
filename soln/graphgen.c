/*
 * Clement Poh
 *
 * This program creates random dag.
 *
 * usage: daggen [<order> <edge_chance> <seed> <graph>]
 *
*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

# define TRUE (1 == 1)
# define FALSE !TRUE

#define DEFAULT_ORDER 10
#define EDGE_CHANCE 35

void init_shuffle(int *labels, int order) {
    for (int i = 0; i < order; i++) {
        /* initialisation using the Knuth-shuffle */
        int j = rand() % (i + 1);
        /* Swap an existing element [j] to position [i] */
        labels[i] = labels[j];

        /* put newly-initialized element [i] in position [j] */
        labels[j] = i;
    }
}

int main(int argc, char *argv[]) {
    int order = argc > 1 ? atoi(argv[1]) : DEFAULT_ORDER;
    int prob = argc > 2 ? atoi(argv[2]) : EDGE_CHANCE;
    int dag = argc > 4 ? FALSE : TRUE;

    int *labels  = calloc(order, sizeof(*labels));
    srand(argc > 3 ? atoi(argv[3]) : time(NULL));

    init_shuffle(labels, order);

    printf("%d\n", order);
    for (int i = 0; i < order; i++) {
        /* print the node label */
        printf("%d\n", labels[i]);
    }

    int imax = dag ? order - 1 : order;
    for (int i = 0; i < imax; i++) {
        int jmin = dag ? i + 1 : 0;
        for (int j = jmin; j < order; j++) {
            if (rand() % 100 < prob)
                printf("%d %d\n", labels[i], labels[j]);
        }
    }

    free(labels);

    return 0;
}