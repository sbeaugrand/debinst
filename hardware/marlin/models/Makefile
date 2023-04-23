# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
OBJECTS  = $(patsubst %.scad,%.stl,$(wildcard *.scad))
OBJECTS := $(addprefix build/,$(OBJECTS))

.SUFFIXES:

.PHONY: all
all: build $(OBJECTS)

build:
	@mkdir build

build/%.stl: %.scad
	openscad -q -o $@ $<
