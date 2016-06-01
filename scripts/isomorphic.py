#!/usr/bin/env python
"""
isomporphic.py

This script returns true if both its input graphs are isomorphic.
The program inputs are expected to be two dot files.

It requires that the pygraphviz and networkx packages are installed.
"""
import sys

try:
    import pygraphviz
    import networkx
except ImportError:
    sys.stdout.write("Import error: pip install networkx pygraphviz\n")
    sys.exit(1)

try:
    G1 = networkx.Graph(pygraphviz.AGraph(sys.argv[1]))
    G2 = networkx.Graph(pygraphviz.AGraph(sys.argv[2]))
except ValueError:
    sys.stderr.write("Invalid dot file\n")
    sys.exit(1)
except pygraphviz.agraph.DotError:
    sys.stderr.write("Invalid dot file\n")
    sys.exit(1)

if networkx.is_isomorphic(G1, G2):
    sys.exit(0)
else:
    sys.exit(1)
