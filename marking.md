COMP20007 Assignment 1 Marking Scheme
=====================================

The `summary.txt` that resides in each student folder was originally intended
to be something that could be shown to students, so it displays rough
information on how the submission went on the test case.

So in the `subs/.../summary.txt` it would say:

    PASS: scripts/isomorphic.py subs/.../out/dag.0010-045.dot ./test/dag.0010-045.dot

Part 1: Graph Input and Output
------------------------------

The `summary.txt` should be mostly sufficient to mark this. However, more
detailed information can be found in the log files on the top level.

The `summary.txt` might say:

    PASS ./test/dag.0010-015.in isomorphic to expected output
    PASS ./test/dag.0010-045.in isomorphic to expected output
    ...
    ... All test cases pass
    ...
    FAIL ./test/dag.1000-000.in could not match expected output

That means the student likely output valid graphs in the dot file format that
are isomorphic to the graphs output by the program and are therefore correct,
even though it reports failure for the tests with a thousand vertices.

So *FAIL*s 1000 vertex graphs may be disregarded if all previous test cases
passed.

### Handling the null graph ###

If the student handles the null graph, i.e. a graph with 0 vertices with an
assertion and fails consistently on all parts, only deduct 0.5 overall.

However if the student passes the null graph test in some cases but not others,
deduct 0.5 at each point of failure.

### Scheme ###

Disregard timeouts on the large graphs.

Mark | Condition
---- | -------------------------------------------------------------------
2    | Passed all test cases.
2    | Passed all test cases but time out on large graphs.
2    | Passed all using `isomorphic.py` but failure on large graphs.
1.5  | Passed all but the null graph.
1    | Passed some test cases.
1    | Up to 1 if minor fix required to source, but otherwise passes.
0    | Failed all.

Part 2: DFS Algorithm for Toposort
----------------------------------

Expect many of the failures here to be caused by not reporting cycles.
Some will only report cycles and not correctly sort the graphs.

Mark | Condition
---- | -------------------------------------------------------------------
2    | Passed all test cases.
2    | Passed all test cases but time out on large graphs.
1.5  | Passed all but the null graph.
1    | Passed some test case DAGs.
0.5  | Correctly reports cycles but does not toposort any DAGs.
1    | Up to 1 if minor fix required to source, but otherwise passes.
0    | Failed all.

Part 3: Kahn Algorithm for Toposort
-----------------------------------

Expect many of the failures here to be caused by not reporting cycles.

Mark | Condition
---- | -------------------------------------------------------------------
2    | Passed all test cases.
2    | Passed all test cases but time out on large graphs.
1.5  | Passed all but the null graph.
1    | Passed some test case DAGs.
0.5  | Correctly reports cycles but does not toposort any DAGs.
1    | Up to 1 if minor fix required to source, but otherwise passes.
0    | Failed all.

Part 4: Verification
------------------------------

In this task, many test cases would pass if the function always returns false.

Mark | Condition
---- | -------------------------------------------------------------------
2    | Passed all test cases.
2    | Passed all test cases but time out on large graphs.
1.5  | Passed all but the null graph.
1    | Passed some test cases.
1    | Up to 1 if minor fix required to source, but otherwise passes.
0    | Failed all.

Part 5: Analysis
------------------------------

Marking for the analysis isn't too stringent. Make sure it makes sense and is
reasonable and plausible, that it shows the student understands the task.

The report will get full marks if it is a succinct, factual report on
running times including a discussion comparing times to big-O bounds.

Coding style
------------
+   Each submitted C file needs an opening comment at the top of the file
    identifying the author. (-1 if more than one file, -0.5 if just one file).

+   If or when taking a cursory look through the code, look for magic numbers,
    and that it isn't too confusing.

+   If the submission is going to get 10/10, make sure `free_graph()` is
    correctly implemented. It must free incoming, and outgoing edges, the
    vertex label and then all the graph vertices. Deduct 0.5 if it does not
    conform to this. Example implementation below:

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


Appendix A: From the specification
----------------------------------

### Submission ###

The four coding parts of the assignment will be marked as follows:

+   You will lose a mark if your submission does not identify you in the
    opening comment of each submitted file.

+   You will lose a mark if your solution is incorrect in some way (breaks on
    certain inputs, has memory leaks, requires fixing to work at all).

+   You will lose a mark if your solution is difficult to interpret (minimal or
    unhelpful comments, obscure variable names).

+   The report will get full marks if it is a succinct, factual report on
    running times including a discussion comparing times to big-O bounds.

+   You will lose marks for missing timing results, missing graph, missing
    big-O discussion.

### Submission ###

+   It should unpack into a folder, where the folder is named using your
    student ID.

+   Submissions not adhering to these requirements will be subject to a 2 point
    penalty.
