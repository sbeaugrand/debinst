# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = knotsvg
PROROOT = ..
PDFOBJECTS = $(patsubst %.py,%.pdf,$(wildcard noeud_*.py))
PDFOBJECTS := $(addprefix build/,$(PDFOBJECTS))
SIZE = $(words $(PDFOBJECTS))
COUNT = 0
PYVER = $(shell python3 -c 'import sys; print("{}.{}".format(sys.version_info.major, sys.version_info.minor))')
BEZIER = $(HOME)/.local/lib/python$(PYVER)/site-packages/bezier

include $(PROROOT)/makefiles/livret.mk

$(PROJECT).pdf: $(PDFOBJECTS)

%.pdf: build %.tex
	@cd build && pdflatex --halt-on-error ../$(PROJECT).tex
	@mv build/$@ $@
	@evince $@

build/noeud_%.pdf: build/noeud_%.svg
	@inkscape -D $^ -o $@

build/noeud_%.svg: noeud_%.py knotsvg.py $(BEZIER)
	python3 $< $@

$(BEZIER):
	pip3 install bezier

.PHONY: landscape
landscape: landscape.pdf
landscape.pdf: $(PROJECT).pdf
	@pdfjam -q --nup 2x1 --landscape -o $@ $< 1,2

.PHONY: vertical
vertical: vertical.pdf
vertical.pdf: $(PROJECT).pdf
	@pdfjam -q --nup 1x2 --angle 90 -o $@ $< 2,1

include $(PROROOT)/makefiles/tar.mk
