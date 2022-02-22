# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# Exemples :
#  cd ~/install/debinst/install-*-fonts/noeuds
#  make install
#  cd -
#
#  make
#  make portrait
#  make portrait P=2,3,4,1
#
#  make PROJECT=extrait
#  make PROJECT=extrait portrait
#
#  make PROJECT=extraitA4
#
# Doc :
#  mupdf /usr/share/doc/texlive-doc/generic/musixtex/musixdoc.pdf
# ---------------------------------------------------------------------------- #
PROJECT ?= cornemuse
PROROOT = ..
include $(PROROOT)/makefiles/livret.mk

%.pdf: build %.tex
	@$(RM) build/$(PROJECT).mx1 build/$(PROJECT).mx2
	@mv build/$(PROJECT).toc build/$(PROJECT).toc.sav; true
	@cd build && TEXINPUTS="..:" pdflatex --halt-on-error ../$(PROJECT).tex
	@cd build && musixflx $(PROJECT).mx1
	@mv build/$(PROJECT).toc.sav build/$(PROJECT).toc; true
	@cd build && TEXINPUTS="..:" pdflatex --halt-on-error ../$(PROJECT).tex
	@mv build/$@ .

.PHONY: landscape
landscape: landscape.pdf
landscape.pdf: $(PROJECT).pdf
	@pdfjam -q --nup 2x1 --landscape -o $@ $<

.PHONY: verif
verif: verif.pdf
	@mupdf $<
	@$(RM) $<

verif.pdf: $(PROJECT).pdf
	@pdfjam -q --nup 2x1 --landscape -o $@ $< {},1-

include $(PROROOT)/makefiles/tar.mk
