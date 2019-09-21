# ---------------------------------------------------------------------------- #
## \file fonts.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = $(shell basename `readlink -f .`)
TARGET = ex$(PROJECT)
TFMDIR = $(HOME)/.texlive2016/texmf-var/fonts/tfm/public/$(PROJECT)
PKDIR  = $(HOME)/.texlive2016/texmf-var/fonts/pk/ljfour/public/$(PROJECT)

.SUFFIXES:

.PHONY: all
all: $(TARGET).pdf

$(TARGET).pdf: $(TARGET).tex build
	cd build && pdflatex --halt-on-error ../$<
	mv build/$@ .

build:
	@mkdir $@

.PHONY: install
install:
	../mfinst.sh $(PROJECT).mf

.PHONY: ttf
ttf:
	mftrace --formats=ttf $(PROJECT).mf

.PHONY: pfb
pfb:
	mftrace --formats=pfb -V \
	--tfmfile=$(TFMDIR)/$(PROJECT).tfm \
	-e ../T1-WGL4.enc $(PROJECT).mf

.PHONY: clean
clean:
	@$(RM) build/*.aux build/*.log *~

.PHONY: mrproper
mrproper: clean
	@$(RM) build/*
	@rmdir build
	$(RM) $(TFMDIR)/$(PROJECT).tfm
	$(RM) $(PKDIR)/$(PROJECT).*pk
