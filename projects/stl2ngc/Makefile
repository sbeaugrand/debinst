# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note sudo apt-get install libopencamlib-dev libboost-dev
##       # https://www.thingiverse.com/thing:2398719/files
##       prusa-slicer claw1.stl
##       # Placer sur une face
##       # Pivoter Z 90
##       # Taille Z
##       # Position X 0 Y 0
##       # Mode expert Imprimantes Forme du plateau Origine x:100 y:100
##       # Exporter le plateau en STL
##       make test1
##       camotics build/claw1-cone.ngc
##       bCNC build/claw1-cone.ngc
##       Probe Pos -10 along Z direction
# ---------------------------------------------------------------------------- #
OCL_DIR = /usr/lib/x86_64-linux-gnu/opencamlib
LDFLAGS = -L$(OCL_DIR) -locl
PROROOT = ..
include $(PROROOT)/makefiles/pro.mk
CMD = LD_LIBRARY_PATH=$(OCL_DIR) build/$(PROJECT)

.PHONY: all
all: build build/$(PROJECT)

include $(PROROOT)/makefiles/ccpp.mk

build/$(PROJECT): $(OBJECTS)
	$(CXX) $^ $(LDFLAGS) -o $@

.PHONY: tests
tests: test1 test2 test3 test4
.PHONY: test1
test1: build build/claw1-cone.ngc
.PHONY: test2
test2: build build/claw2-cone.ngc
.PHONY: test3
test3: build build/claw1-cyl.ngc
.PHONY: test4
test4: build build/claw2-cyl.ngc

build/%-cone.ngc: build/%.stl build/$(PROJECT)
	cat $< | $(CMD) -d 3.175 -l 0 -a 30 -z y >$@

build/%-cyl.ngc: build/%.stl build/$(PROJECT)
	cat $< | $(CMD) >$@

include $(PROROOT)/makefiles/tar.mk
