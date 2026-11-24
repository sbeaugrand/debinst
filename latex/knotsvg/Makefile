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
INKEXT = $(HOME)/.config/inkscape/extensions

include $(PROROOT)/makefiles/livret.mk

$(PROJECT).pdf: $(PDFOBJECTS)

%.pdf: build %.tex
	@cd build && pdflatex --halt-on-error ../$(PROJECT).tex
	@mv build/$@ $@
	@evince $@

build/noeud_%.pdf: build/noeud_%.svg
	@inkscape -D $^ -o $@

build/noeud_%.svg: noeud_%.py knotsvg.py
	python3 $< $@

.PHONY: inkscape
inkscape:
	@mkdir -p $(INKEXT)
	@ln -sf $(CURDIR)/inkscape/knotsvg_inkscape.py $(INKEXT)/
	@ln -sf $(CURDIR)/inkscape/knotsvg.inx $(INKEXT)/
	@ln -sf $(CURDIR)/knotsvg.py $(INKEXT)/

.PHONY: svg
svg:
	@python3 inkscape/gensvg.py

.PHONY: landscape
landscape: landscape.pdf
landscape.pdf: $(PROJECT).pdf
	@pdfjam -q --nup 2x1 --landscape -o $@ $< 1,2

.PHONY: vertical
vertical: vertical.pdf
vertical.pdf: $(PROJECT).pdf
	@pdfjam -q --nup 1x2 --angle 90 -o $@ $< 2,1

include $(PROROOT)/makefiles/tar.mk
