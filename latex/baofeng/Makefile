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
# Fichier pour git diff
#   make baofeng4diff.csv
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
PORT   = /dev/ttyUSB0
RTYPE  = UV-82WP
SRCDIR = $(shell pwd)
include $(PROROOT)/makefiles/livret.mk

$(PROJECT).pdf: build build/table1.tex build/table2.tex

build/table1.tex: build/table.tex
	@sed '66,$$d' $< >$@

build/table2.tex: build/table.tex
	@sed '2,65d' $< >$@

build/table.tex: $(PROJECT).csv csv2tex.sh
	@csv2tex.sh $< $@

$(PROJECT)4diff.csv: $(PROJECT).csv
	@sed 's/^[^,]*,//' $< >$@

.PHONY: clone
clone: $(CHIRP)/chirpw

.PHONY: upload
upload: $(IMG) $(CHIRP)/chirpw
	@cd $(CHIRP) && \
	sudo python -c '\
	img="'$(SRCDIR)/$<'"; \
	csv="'$(SRCDIR)/$(PROJECT).csv'"; \
	port="'$(PORT)'"; \
	rtype="'$(RTYPE)'"; \
	execfile("'$(SRCDIR)/upload.py'")'

$(CHIRP)/chirpw:
	hg clone http://d-rats.com/hg/chirp.hg $(CHIRP)

$(IMG):

include $(PROROOT)/makefiles/tar.mk
