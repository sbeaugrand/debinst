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
# ---------------------------------------------------------------------------- #
PROJECT = cornemuse

.SUFFIXES:

.PHONY: all
all:
	@mv $(PROJECT).toc $(PROJECT).toc.sav; true
	@pdflatex --halt-on-error $(PROJECT).tex
	@musixflx $(PROJECT).mx1
	@mv $(PROJECT).toc.sav $(PROJECT).toc; true
	@pdflatex --halt-on-error $(PROJECT).tex
	@$(RM) $(PROJECT).mx* $(PROJECT).aux $(PROJECT).log

.PHONY: livret
livret: livret-$(PROJECT).pdf
livret-$(PROJECT).pdf: $(PROJECT).pdf
	@pdfbook -q -o $@ $< $(P)

.PHONY: portrait
portrait: portrait-$(PROJECT).pdf
portrait-$(PROJECT).pdf: livret-$(PROJECT).pdf
	@pdf90 -q -o $@ $<

.PHONY: verif
verif: verif.pdf
	@mupdf $<
	@$(RM) $<

verif.pdf: $(PROJECT).pdf
	@pdfjam -q --nup 2x1 --landscape -o $@ $< {},1-

.PHONY: clean
clean:
	@$(RM) *~

PROROOT = ..
include $(PROROOT)/makefiles/tar.mk
