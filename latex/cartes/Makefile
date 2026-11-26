# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note rm -f page.tex && make && mupdf -r 83 cartes.pdf
##       rm -f page.tex && make L="1 3 5 7 9" && mupdf -r 83 cartes.pdf
# ---------------------------------------------------------------------------- #
PROJECT = cartes
PROROOT = ..

$(PROJECT).pdf: page.tex

page.tex: liste-pr-.tex liste2page.awk
	@cat $< | ./liste2page.awk - $(L) >$@

include $(PROROOT)/makefiles/pdf.mk
