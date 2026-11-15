# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# Prefixe des fichiers <COEFFS>-0.txt, -1.txt et -2.txt (cf. make coeffs)
COEFFS ?= ../../build/coeffs$(shell date +%Y)-$(shell date +%Y)
BDIR ?= build
DEST ?= /sdcard/Download

COEFFS_FILES = $(addprefix $(COEFFS)-,0.txt 1.txt 2.txt)
COEFFS_FOUND = $(if $(word 3,$(wildcard $(COEFFS_FILES))),$(COEFFS_FILES))

.PHONY: all
all: $(BDIR)/soleil.html

.PHONY: help
help:
	@echo
	@echo "make [COEFFS=../../build/coeffs2026-2033]"
	@echo "make test [COEFFS=...]"
	@echo "make install"
	@echo

$(BDIR)/icon.png: icon.svg
	@mkdir -p $(BDIR)
	rsvg-convert -w 192 -h 192 $< -o $@

# Fichier HTML autonome : soleil.js, icone et coefficients integres
$(BDIR)/soleil.html: index.html soleil.js $(BDIR)/icon.png FORCE
	@mkdir -p $(BDIR)
	@$(if $(COEFFS_FOUND),echo "coefficients : $(COEFFS)",\
	 echo "pas de coefficients integres ($(COEFFS)-[012].txt)")
	@C="$$(cat $(COEFFS_FOUND) /dev/null | sed -z 's/\n/\\n/g')"\
	 I="data:image/png;base64,$$(base64 -w0 $(BDIR)/icon.png)"\
	 awk '/href="icon.png"/ { sub(/icon.png/, ENVIRON["I"]) }\
	 /<script src="soleil.js"><\/script>/ {\
	  print "<script>"; system("cat soleil.js"); print "</script>"; next }\
	 /^const DEFAULT = .*;$$/ {\
	  print "const DEFAULT = \047" ENVIRON["C"] "\047;"; next }\
	 { print }' $< >$@
	@ls -l $@

.PHONY: FORCE
FORCE:

.PHONY: test
test: test.js soleil.js
	@cat $(COEFFS_FILES) | node test.js

.PHONY: install
install: $(BDIR)/soleil.html
	adb push $< $(DEST)/soleil.html

.PHONY: clean
clean:
	@$(RM) -r $(BDIR) *~
