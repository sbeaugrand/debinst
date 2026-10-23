# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note sudo apt-get install libopencamlib-dev libboost-dev
##
##       # Exemple 1
##       # https://www.thingiverse.com/thing:2398719/files
##       prusa-slicer claw1.stl
##       # Placer sur une face
##       # Pivoter Z 90
##       # Taille Z
##       # Position X 0 Y 0
##       # Mode expert Imprimantes Forme du plateau Origine x:100 y:100
##       # Exporter le plateau en STL
##       make build/claw1-cone-r.ngc
##       camotics build/claw1-cone-r.ngc
##       bCNC build/claw1-cone-r.ngc
##       # $30=12000
##       # Probe Pos -10 along Z direction
##       gcodesender.py -f build/claw1-cone-r.ngc 2> >(tee err.log >&2)
##
##       # Exemple 2
##       cd ../../latex/openscad/models && make build/runeDagaz.stl && cd -
##       cp ../../latex/openscad/models/build/runeDagaz.stl build/
##       make build/runeDagaz-cyl-r.ngc ARGS="-z y -s 4 -d 1.99 -c"
##       camotics build/runeDagaz-cyl-r.ngc  # Tool 2mm
##       gcodesender.py -f build/runeDagaz-cyl-r.ngc 2> >(tee err.log >&2)
##       # (Les fibres du bois en direction des y.)
##       # Accentuer les coins au couteau de precision
##       # Faire couler 60cm d'etain 97% en bobine de 2mm de diametre (ou 14g)
##       # Secouer le tasseau a plat pour repartir l'etain
##       # Vernir les creux en couleur et poncer au 80, 120 puis 400
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

build/%-cone-r.ngc: build/%-cone.ngc reduce.awk
	./reduce.awk $< >$@
	sed -i 's/G21 F.*/G21 F200/' $@

build/%-cyl-r.ngc: build/%-cyl.ngc reduce.awk
	./reduce.awk $< >$@
	sed -i 's/G21 F.*/G21 F100/' $@

build/%-cone.ngc: build/%.stl build/$(PROJECT)
	cat $< | $(CMD) -d 3.175 -l 0 -a 30 -z y $(ARGS) >$@

build/%-cyl.ngc: build/%.stl build/$(PROJECT)
	cat $< | $(CMD) $(ARGS) >$@

include $(PROROOT)/makefiles/tar.mk
