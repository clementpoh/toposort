# Makefile
#
# Clement Poh
#
# Makefile for assignment one of COMP20007 2016.
#
# Replace '<STUDENT-ID>' with your Student ID e.g. 269508
STUDENTID = 269508
SUBMIT	= toposort.c graph.c graphio.c report.pdf

# Define the C compiler
CC      = gcc

# Define the compiler flags
#  -Wall to turn on most of the warnings
#  -Wextra to turn on even more warnings
#  -Wpedantic to turn on even more warnings
#  -ansi to ensure ansi compliance
#  -std=c99 to ensure c99 compliance
#  -m32 to compile for 32 bit architectures
#  -O0 to turn off optimisations
#  -g  to include debugging symbols
#  -pg for profiling
CFLAGS  = -Wall -Wextra -Wpedantic -ansi -std=c99 -m32 -g -O0

# Define any libraries to be linked
LIB		=

# Define the source, header and object files
HDR		= list.h graph.h graphio.h toposort.h
SRC		= list.c graph.c graphio.c toposort.c main.c
OBJ     = $(SRC:.c=.o)

# The executable name
TARGET	= soln

.PHONY: all
all: graphgen $(TARGET)

$(TARGET): $(OBJ) Makefile
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ) $(LIB)

submission: $(SUBMIT)
	tar -czvf $(STUDENTID).tar.gz $(SUBMIT)

graphgen: graphgen.c
	$(CC) $(CFLAGS) -o graphgen graphgen.c

.PHONY: clean
clean:
	rm -f $(OBJ) *.dot *.png tmp.*

.PHONY: clobber
clobber: clean
	rm -f $(TARGET) tags graphgen *.exe $(STUDENTID).tar.gz

.PHONY: usage
usage: $(TARGET)
	./$(TARGET)

.PHONY: debug
debug: $(TARGET)
	gdb ./$(TARGET)

tags:
	ctags -w $(SRC)

$(OBJ): $(HDR)
