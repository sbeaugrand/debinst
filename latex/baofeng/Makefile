# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# Construction d'un pdf des frequences, au choix :
#   make
#   make livret
#   make portrait
# ---------------------------------------------------------------------------- #
# Exemple d'upload pour baofeng UV-9R+
#   vi Makefile  # set CHIRP
#   make clone
#   cd <CHIRP>
#   sudo ./chirpw
#   Radio => Download From Radio
#     /dev/ttyUSB0
#     Baofeng
#     UV-82WP
#   Save As => baofeng-pr-uv9r+.img
#   vi Makefile  # set IMG, PORT, RTYPE
#   make upload
# ---------------------------------------------------------------------------- #
PROJECT = baofeng
PROROOT = ..
CHIRP  = $(HOME)/data/install-build/chirp
IMG    = baofeng-pr-uv9r+.img
SRC    = baofeng
DST    = frequences
PORT   = /dev/ttyUSB0
RTYPE  = UV-82WP
SRCDIR = $(shell pwd)

.SUFFIXES:

.PHONY: all
all: build $(DST).pdf $(SRC)4diff.csv

build:
	@mkdir $@

$(DST).pdf: $(DST).tex build/table1.tex build/table2.tex
	@cd build && pdflatex --halt-on-error ../$<
	mv build/$@ .

build/table1.tex: build/table.tex
	@sed '66,$$d' $< >$@

build/table2.tex: build/table.tex
	@sed '2,65d' $< >$@

build/table.tex: $(SRC).csv csv2tex.sh
	@csv2tex.sh $< $@

.PHONY: livret
livret: build livret-$(DST).pdf
livret-$(DST).pdf: $(DST).pdf
	pdfbook -q -o $@ $<

.PHONY: portrait
portrait: build portrait-$(DST).pdf
portrait-$(DST).pdf: livret-$(DST).pdf
	pdf90 -q -o $@ $<

$(SRC)4diff.csv: $(SRC).csv
	@sed 's/^[^,]*,//' $< >$@

.PHONY: clone
clone: $(CHIRP)/chirpw

.PHONY: upload
upload: $(IMG) $(CHIRP)/chirpw
	@cd $(CHIRP) && \
	sudo python -c '\
	img="'$(SRCDIR)/$<'"; \
	csv="'$(SRCDIR)/$(SRC).csv'"; \
	port="'$(PORT)'"; \
	rtype="'$(RTYPE)'"; \
	execfile("'$(SRCDIR)/upload.py'")'

$(CHIRP)/chirpw:
	hg clone http://d-rats.com/hg/chirp.hg $(CHIRP)

$(IMG):

.PHONY: clean
clean:
	@$(RM) build/*.tex build/*.aux build/*.log *~

.PHONY: mrproper
mrproper: clean
	@rmdir build/
	@$(RM) *.pdf

include $(PROROOT)/makefiles/tar.mk
