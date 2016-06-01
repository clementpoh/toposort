# Makefile
#
# Clement Poh
#
# Makefile to test COMP20007 2016 Assignment 1 submissions
#

STUDENT = subs/soln

# Subdirectories
SOLNDIR	= soln
SUBDIR	= subs
SCRIPTS = scripts
TESTDIR	= test
SKELDIR = skeleton

# Solution binaries
SOLN	= $(SOLNDIR)/soln
GRAPHGEN= $(SOLNDIR)/graphgen

# Scripts to execute
FOREACH = $(SCRIPTS)/foreach.sh
COMPILE = $(SCRIPTS)/compile.sh
UNPACK  = $(SCRIPTS)/unpack.sh
PRINT	= $(SCRIPTS)/print.sh
TOPOSORT= $(SCRIPTS)/toposort.sh
VERIFY	= $(SCRIPTS)/verify.sh
TESTGEN = $(SCRIPTS)/testgen.sh

# Header and source files submissions depend on
HDR		= $(wildcard $(SKELDIR)/*.h)
SRC		= $(SOLNDIR)/main.c $(SKELDIR)/list.c

# The submission of an individual student
SUBS	= $(shell /usr/bin/find $(SUBDIR) -mindepth 1 -maxdepth 1 -type d)
STUDBIN = $(addsuffix /ass1,$(SUBS))

# Test artifacts
STUDSUMMARY	= $(addsuffix /summary.txt,$(SUBS))
STUDMAKE	= $(addsuffix /out/make.txt,$(SUBS))
STUDPRINT	= $(addsuffix /out/print.txt,$(SUBS))
STUDDFS 	= $(addsuffix /out/dfs.txt,$(SUBS))
STUDKAHN	= $(addsuffix /out/kahn.txt,$(SUBS))
STUDVERIFY	= $(addsuffix /out/verify.txt,$(SUBS))

# Expected outputs
DOTS	= $(patsubst %.in,%.dot,$(wildcard $(TESTDIR)/*.in))

DFS		= $(patsubst %.in,%.dfs,$(wildcard $(TESTDIR)/dag.*.in))
KAHN	= $(patsubst %.in,%.kahn,$(wildcard $(TESTDIR)/dag.*.in))

# Rules

.PHONY: all
all: $(SOLNDIR) test $(DOTS) $(DFS)
	@echo -e "Usage:"
	@echo -e "make summaries:\ttest each untested submission"
	@echo -e "make complete:\ttest all submissions from scratch"
	@echo -e "make student:\ttest STUDENT, now: $(STUDENT)"
	@echo -e "make subs/dir:\ttest subs/dir"

.PHONY: student
student: $(STUDENT)/summary.txt

spec.pdf: spec.tex
	pdflatex $< && rm spec.log spec.aux

spec.md: spec.tex
	pandoc -w markdown_github -o $@ $<

.PHONY: $(SOLNDIR)
$(SOLNDIR): $(GRAPHGEN) $(SOLN)

.SECONDARY: $(SOLN) $(GRAPHGEN)
$(GRAPHGEN) $(SOLN):
	$(MAKE) -C $(SOLNDIR)
	$(MAKE) -C $(SOLNDIR) clean

# Rules to run tests on all submissions
.PHONY: complete unpack compile print dfs verify
complete: print.log dfs.log kahn.log verify.log $(STUDSUMMARY)

unpack: unpack.log
unpack.log: $(UNPACK)
	$(UNPACK) $(SUBDIR) 2>&1 | tee unpack.log

compile: compile.log
compile.log: $(COMPILE) unpack.log
	$(FOREACH) $(COMPILE) $(SUBDIR) 2>&1 | tee compile.log

print: print.log
print.log: $(PRINT) $(DOTS) compile.log
	$(FOREACH) $(PRINT) $(SUBDIR) 2>&1 | tee print.log

dfs: dfs.log
dfs.log: $(TOPOSORT) $(SOLN) compile.log
	$(FOREACH) $(TOPOSORT) $(SUBDIR) 2>&1 | tee dfs.log

kahn: kahn.log
kahn.log: $(TOPOSORT) $(SOLN) compile.log
	$(FOREACH) $(TOPOSORT) -m 2 $(SUBDIR) 2>&1 | tee kahn.log

verify: verify.log
verify.log: $(VERIFY) $(SOLN) compile.log
	$(FOREACH) $(VERIFY) $(SUBDIR) 2>&1 | tee verify.log

# Rules to generate test cases

# Generates input graphs
.PHONY: test
test: $(SOLN)
	$(TESTGEN) $(TESTDIR) $(GRAPHGEN)

# $(DOTS) expands to the next rule
$(TESTDIR)/%.dot: $(TESTDIR)/%.in $(SOLN)
	$(SOLN) -p $@ $<

$(TESTDIR)/%.dfs: $(TESTDIR)/%.in $(SOLN)
	$(SOLN) -m 1 $< > $@ 2> /dev/null

$(TESTDIR)/%.kahn: $(TESTDIR)/%.in $(SOLN)
	$(SOLN) -m 2 $< > $@ 2> /dev/null

# Rule for untested submissions
.PHONY: summaries
summaries: $(STUDSUMMARY)

# Rules for an individual submission
.PHONY: $(SUBS)
$(SUBS): % : %/summary.txt

# Rule to compile the student binary
.SECONDARY: $(STUDBIN)
$(STUDBIN): %/ass1 : %/graphio.c %/graph.c %/toposort.c $(HDR) $(SRC)
	-$(COMPILE) $(@D)

$(STUDPRINT): %/out/print.txt : %/ass1 $(PRINT) $(DOTS)
	-$(PRINT) $(subst /out,,$(@D))

$(STUDDFS): %/out/dfs.txt : %/ass1 $(TOPOSORT) $(SOLN)
	-$(TOPOSORT) $(subst /out,,$(@D))

$(STUDKAHN): %/out/kahn.txt : %/ass1 $(TOPOSORT) $(SOLN)
	-$(TOPOSORT) -m 2 $(subst /out,,$(@D))

$(STUDVERIFY): %/out/verify.txt : %/ass1 $(VERIFY) $(DFS) $(SOLN)
	-$(VERIFY) $(subst /out,,$(@D))

$(STUDSUMMARY): %/summary.txt : %/ass1 \
   	%/out/print.txt %/out/dfs.txt %/out/kahn.txt %/out/verify.txt
	-cat $(@D)/lms.txt > $@
	-cat $(@D)/out/make.txt >> $@
	-cat $(@D)/out/print.txt >> $@
	-cat $(@D)/out/dfs.txt >> $@
	-cat $(@D)/out/kahn.txt >> $@
	-cat $(@D)/out/verify.txt >> $@

# Rules to clean up
.PHONY: clean
clean:
	$(MAKE) -C $(SOLNDIR) clobber
	-rm -rf spec.pdf \
		$(SUBDIR)/**/ass1 \
		$(SUBDIR)/**/*.exe \
	   	$(SUBDIR)/**/*.h \
		$(SUBDIR)/**/list.c \
		$(SUBDIR)/**/main.c \
		$(SUBDIR)/**/Makefile

.PHONY: mostlyclean
mostlyclean: clean
	-rm -rf \
		$(TESTDIR)/*.dot \
		$(TESTDIR)/*.rev \
		$(TESTDIR)/*.dfs \
		$(TESTDIR)/*.kahn \
		$(TESTDIR)/graph.*-*.in \
		$(TESTDIR)/dag.*-*.in \
	   	$(SUBDIR)/**/out

.PHONY: clobber
clobber: mostlyclean
	-rm -rf *.log \
	   	$(SUBDIR)/**/summary.txt
