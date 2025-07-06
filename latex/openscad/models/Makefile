# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Usage: make
#               cd subdir && make -f ../Makefile
# ---------------------------------------------------------------------------- #
OBJECTS  = $(patsubst %.scad,%.stl,$(wildcard *.scad))
OBJECTS += $(patsubst %.svg,%.pdf,$(wildcard *.svg))
OBJECTS := $(addprefix build/,$(OBJECTS))

.SUFFIXES:

.PHONY: all
all: build $(OBJECTS)

build:
	@mkdir build

build/%.stl: %.scad
	openscad -q -D export=true -o $@ $<

build/%.pdf: %.svg
	rsvg-convert -f pdf -o $@ $<
