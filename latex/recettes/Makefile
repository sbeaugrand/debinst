# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = recettes
PROROOT = ../..

include $(PROROOT)/makefiles/livret.mk

recettes.pdf:\
 empty.pdf\
 savon.pdf\
 pneu.pdf\

	@#pdfjam -q -o $@ $< '{}' $^
	@pdfjam -q -o $@ $^

empty.pdf\
 savon.pdf\
 pneu.pdf\
: %.pdf: %.tex
	@echo TEXINPUTS=$(TEXINPUTS)
	@mkdir -p build && cd build && export TEXINPUTS=$(TEXINPUTS) &&\
	 pdflatex --halt-on-error ../$<
	@mv build/$@ .
