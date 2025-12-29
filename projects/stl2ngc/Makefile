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
	cat $< | LD_LIBRARY_PATH=$(OCL_DIR) build/$(PROJECT) 3.175 0 30 >$@

build/%-cyl.ngc: build/%.stl build/$(PROJECT)
	cat $< | LD_LIBRARY_PATH=$(OCL_DIR) build/$(PROJECT) 2 6 >$@

include $(PROROOT)/makefiles/tar.mk
