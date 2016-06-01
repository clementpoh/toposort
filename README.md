Design of Algorithms Assignment 1
=================================

This is the solution and test suite for COMP20007 Design of Algorithms
Assignment 1 semester 1 2016.

Students were tasked with implementing topological sorting algorithms in C.
The detailed specification can be found in the file _spec.tex_.

Compatibility
-------------

The scripts and non-student source files were designed for Unix platforms. They
were written, tested and executed in _Linux_; So it should work
without difficulty on most Linux distributions.

The scripts were also run and tested on _MinGW_, working with slight
differences. The exit codes that are returned by programs running in _MinGW_
differ to conventional Unix exit codes.

The list module uses an internal function in its implementation of `filter()`.
The default C compiler on _OSX_ does not support these extensions, so either
the _filter()_ function definition needs to be deleted or the GNU C compiler
needs to be installed when running the scripts on Mac computers.

Usage
-----

The Makefile takes care of the dependencies. It automatically builds each
submission, solution, and expected outputs where necessary.

The following commands are most important:

### Generating tests ###

A limited number of test cases are provided, the rest are generated. The
following command is used to generate them.

+   `make`

    The command generates a host of pseudo-random graphs in _test/_.

    The random seed is defined in `testgen.sh` and may be changed to generate
    different graphs.

### Testing one submission ###

The following commands test one submission.

+   `make student`

    Runs the full test suite on an individual submission. The student is
    defined by the _STUDENT_ variable at the top of the `Makefile`.

    This command attempts to compile the submission, test the printing
    functionality of the submission against the graphs in _test/_.

+   `make subs/subdirectory`

    Like the command above, runs the full test suite on _subs/subdirectory_.

### Cleaning up ###

Because of the sheer complexity of the directory structure there are three
commands for keeping things tidy.

+   `make clean`
    + Cleans the solution directory
    + Deletes the header files, `Makefile`, `list.c`, and `main.c` from all the
      submission directories.
    + Deletes the `ass1` binary from all the submission directories.

+   `make mostlyclean`
    + Does everything `make clean` does.
    + Deletes all the generated graphs from the _test/_ directory.
    + Deletes all the generated dot files from the _test/_ directory.
    + Deletes all the DFS and Kahn vertex sequences from the _test/_ directory.
    + Deletes the output dot files, and vertex sequences from the submission
      directories.
    + Deletes the print, DFS, Kahn and verify reports from the submission
      directories.

+   `make clobber`
    + Does everything `make mostlyclean` does.
    + Deletes the summary report.

### Testing all submissions ###

Running the test cases

The following commands test all the submissions in the _subs/_ directory:
Each submission is by default given *120 seconds* to run through all the input
tests.  The timeout can be revised in the `scripts/foreach.sh` file.

+   `make summaries`

    Compiles the summaries in each submission folder. If the summary.txt is out
    of date, or does not exist, make will run the tests necessary to create it.

+   `make compile`

    Attempts to compile each submission in _subs/_. This doesn't need to be
    called, as the testing rules depend on _compile.log_.

    The results that are printed to stdout is also piped to _compile.log_.

+   `make print`

    Tests the printing functionality of each submission in _subs/_ against the
    graphs _test/_.

    The results that are printed to stdout is also piped to _print.log_.

+   `make dfs`

    Tests the DFS toposort implementation of each submission in _subs/_
    against the graphs _test/_.

    The results that are printed to stdout is also piped to _dfs.log_.

+   `make kahn`

    Tests the Kahn toposort implementation of each submission in _subs/_
    against the graphs _test/_.

    The results that are printed to `stdout` is also piped to _kahn.log_.

+   `make verify`

    Tests the `verify()` implementation of each submission in _subs/_ against
    the DAGs in _test/_. It uses the DFS ordering of each graph as input to
    each of the graphs with the same number of vertics.

    The results that are printed to `stdout` is also piped to _verify.log_.

+   `make complete`

    Runs all the tests on all the submissions.

Test scripts
------------

A limited number of test cases are provided, the rest are generated. Test cases
reside in the _test/_ directory.

The scripts used for testing reside in the _scripts/_ directory. It is best to
run the scripts through `make` than to run them from the command line. Make
takes care of the dependencies and the paths.

Each of the test scripts first look for the existence of the binary. 127 is
returned if the binary, `ass1`, can't be found.

### Test reports ###

Each script keeps a log and it also prints separately to `stdout`.

The messages printed to `stdout` are a human readable form of the program exit
signal when run on a test case and the command that was called on the test case.

Below is a table of common signals and what they mean in the context of the
assignment.

| Signal | Meaning                                                      |
| ------ | ------------------------------------------------------------ |
| `PASS` | Output matches expected output                               |
| `FAIL` | `EXIT_SUCCESS` but output does not match expected output     |
| `EXIT` | `EXIT_FAILURE` is unexpected or issue with submission output |
| `TERM` | Program terminated, usually timeout                          |
| `KILL` | Program killed, usually timeout                              |
| `SEGV` | Segmentation fault                                           |
| `ABRT` | Program aborted, assertion failure or memory errors          |
| `255`  | Exit was called incorrectly                                  |

The log resides in the _out/_ directory of the submission folder. The log
states whether a test either passed or failed, any program output and shell
messages.

### Submission summary vs top level logs ###

The `summary.txt` that resides in each student folder was originally intended
to be something that could be shown to students, so it displays rough
information on how the submission went on the test case.

So in the `subs/.../summary.txt` it presents the command used to get the result:

    PASS: scripts/isomorphic.py subs/.../out/dag.0010-045.dot ./test/dag.0010-045.dot

### Test case timeout ###

Each individual test case is given *9 seconds* to run through an individual test
case before it is terminated or killed. The timeout can be revised in the
`scripts/timeout.sh` file.

If a test case is terminated, it will appear as a *TERM* or *KILL*in the
report, even if if it may actually be correct.

### Generating tests ###

The script `scripts/testgen.sh` generates graphs that can be used as inputs to
the students' programs. It depends on `soln/graphgen` and outputs specific
pseudo-random graphs. More information can be found in the Generated graphs
section.

### Testing print ###

The `print.sh` script is used to test the `print_graph()` functionality of a
submission.

#### Matching graphs ####

The variation of dot files in part 1 is quite incredible. `print.sh` first
attempts to match the students' dot file against two dot files output by
`soln` using `diff`. The graph, and the where edge order is reversed.

If that doesn't work `isomorphic.py` is run to check whether the dot files are
isomorphic to the expected output. For large graphs this can take a while, so
the script is only allowed to run for one second before it's terminated.

If the script is terminated, it will appear as a *FAIL* in the `print.txt`
report, even if the student's dot file really is isomorphic to the solution's.

The script `isomorphic.py` requires `networkx` and `pygraphviz`.  The packages
can be installed through `pip install networkx pygraphviz`.

Test artifacts
--------------

### Generated graphs ###

+   Graphs that may include cycles are named: `graph.order-edge.in`.
    + _order_ is the number of vertices.
    + _edge_ is the percentage chance there is an edge between vertices.

+   DAGs are named: `dag.order-edge.in`
    + _order_ is the number of vertices.
    + _edge_ is the percentage chance there is an edge between a vertex and a
      subsequent vertex.

The directory structure is below:

    test/
    ├── dag.0010-015.in     #   10 vertices, 15% chance of edges DAG
    ├── dag.0010-045.in
    ├── dag.0100-015.in
    ├── dag.0100-045.in
    ├── dag.1000-000.in     # 1000 vertices, 0 edges, empty graph
    ├── dag.1000-015.in
    ├── dag.1000-045.in
    ├── dag.1000-100.in     # 1000 vertices, fully connected DAG
    ├── dag.empty.in        #   10 vertices, 0 edges
    ├── dag.maxline.in      #    5 vertices, to test vertex labels lengths
    ├── dag.path.in         #   10 vertices, simple path
    ├── dag.t1.in
    ├── dag.t2.in
    ├── dag.t3.in
    ├── graph.0010-035.in   #   10 vertices, graph with 35% chance of edges
    ├── graph.0100-035.in
    ├── graph.1000-035.in
    ├── graph.1000-100.in   # 1000 vertices, 1000000 edges, fully connected
    ├── graph.loop.in       #    5 vertices, connected to themselves
    ├── null.in             #    0 vertices
    ├── *.dot               # Output of soln -p
    ├── *.dot.rev           # Output of soln -p with vertices reversed
    └── *.dfs               # Output of soln -m 1, used for testing verify

### Submission testing ###

After `make subs/user-STUDENTID` the submission directory contents are as
follows:

    subs/user-STUDENTID/
    ├── ass1
    ├── graph.c
    ├── graph.h         # Copied from ./skeleton
    ├── graphio.c
    ├── graphio.h       # Copied from ./skeleton
    ├── list.c          # Copied from ./skeleton
    ├── list.h          # Copied from ./skeleton
    ├── lms.txt         # From the LMS
    ├── main.c          # Copied from ./soln
    ├── Makefile        # Copied from ./skeleton
    ├── out
    │   ├── *.dot       # Generated during the print stage
    │   ├── *.dfs       # Generated during the dfs stage
    │   ├── *.kahn      # May be generated during the kahn stage
    │   ├── make.txt    # The compiler warnings and errors
    │   ├── print.txt   # The results of the print stage
    │   ├── dfs.txt     # The results of the dfs stage
    │   ├── kahn.txt    # The results of the kahn stage
    │   └── verify.txt  # The results of the verify stage
    ├── report.pdf
    ├── summary.txt     # The results of all test stages
    ├── toposort.c
    └── toposort.h      # Copied from ./skeleton

    1 directory, 42 files

The new main.c
--------------

The `main.c` that is copied to each submission through the compilation process
differs to the `main.c` provided to the students as skeleton code.

+   It does not call the functions `free_graph()` at the end of the program
    unless the program is called with a new option -f.

+   It does not print out clock ticks and other performance information.

Directory structure
-------------------

This is a diagram of the whole directory structure with short descriptions for
notable files.

    toposort
    ├── compile.log         # Generated with make compile
    ├── print.log           # Generated with make print
    ├── dfs.log             # Generated with make dfs
    ├── kahn.log            # Generated with make kahn
    ├── verify.log          # Generated with make verify
    ├── orig                # The original solution
    │   ├── graph.c
    │   ├── graph.h
    │   ├── graphio.c
    │   ├── graphio.h
    │   ├── list.c
    │   ├── list.h
    │   ├── main.c
    │   ├── Makefile
    │   ├── test
    │   │   └── ...
    │   ├── toposort.c
    │   └── toposort.h
    ├── README.md           # This file
    ├── scripts
    │   ├── compile.sh
    │   ├── foreach.sh      # Runs $1 on all subdirectories of last argument
    │   ├── isomorphic.py   # Returns 0 if argument dot files are isomorphic
    │   ├── print.sh
    │   ├── testgen.sh
    │   ├── timeout.sh      # Terminates commands that run too long
    │   ├── toposort.sh
    │   ├── unpack.sh       # Used to unpack the zip from the LMS
    │   └── verify.sh
    ├── spec.tex            # The specification distributed to students
    ├── skeleton            # Skeleton code posted on LMS
    │   ├── graph.c
    │   ├── graph.h         # Copied to submission
    │   ├── graphio.c
    │   ├── graphio.h       # Copied to submission
    │   ├── list.c          # Copied to submission
    │   ├── list.h          # Copied to submission
    │   ├── main.c
    │   ├── Makefile        # Copied to submission
    │   ├── test
    │   │   └── ...
    │   ├── toposort.c
    │   └── toposort.h      # Copied to submission
    ├── soln                # Solution edited for testing
    │   ├── graph.c
    │   ├── graphgen        # Creates random graphs and DAGs
    │   ├── graph.h
    │   ├── graphio.c
    │   ├── graphio.h
    │   ├── list.c
    │   ├── list.h
    │   ├── main.c          # Copied to submission
    │   ├── Makefile
    │   ├── soln            # Solution binary, renamed from ass1
    │   ├── graphgen.c      # Edited daggen.c to output graphs and DAGs
    │   ├── toposort.c
    │   └── toposort.h
    ├── subs
    └── test
        ├── dag.empty.in    # 10 vertices, 0 edges
        ├── dag.maxline.in  #  5 vertices, tests input line length
        ├── dag.path.in     # 10 vertices, simple path
        ├── dag.t1.in
        ├── dag.t2.in
        ├── dag.t3.in
        ├── graph.loop.in   #  5 vertices, connected to themselves
        └── null.in         #  0 vertices

    9 directories, 77 files

