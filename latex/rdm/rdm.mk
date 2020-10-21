# ---------------------------------------------------------------------------- #
## \file rdm.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
ifeq ($(idir),)
 REPO  = $(HOME)/install/repo
else
 REPO  = $(idir)/../repo
endif
BDIR   = $(HOME)/data/install-build
PYBAR  = $(BDIR)/pyBar
EPB_SI = $(BDIR)/EPB_SI

PROJECT = $(shell basename `readlink -f .`)
DAT2SVG = ../dat2svg.py
SRCDIR  = $(shell pwd)
PDFOBJECTS = $(patsubst %.dat,build/%.pdf,$(wildcard *.dat))
SVGOBJECTS = $(patsubst %.dat,build/%.svg,$(wildcard *.dat))

.SUFFIXES:

.PHONY: all
all: $(PROJECT).pdf

$(PROJECT).pdf: $(PROJECT).tex\
 build $(REPO) $(PDFOBJECTS) $(EPB_SI)/EPB_SI.sty build/EPB_SI
	@cd build && pdflatex --halt-on-error ../$<
	@mv build/$@ .

build $(REPO):
	@mkdir $@

$(PDFOBJECTS): build/defo%.pdf: build/defo%.svg
	@rsvg-convert -f pdf -o $@ $<

$(SVGOBJECTS): build/defo%.svg: defo%.dat $(DAT2SVG) $(PYBAR)/pyBar.py
	cd $(PYBAR) && \
	python -c '\
	src="'$(SRCDIR)/$<'"; \
	dst="'$(SRCDIR)/$@'"; \
	execfile("'$(SRCDIR)/$(DAT2SVG)'")'

$(PYBAR)/pyBar.py:
	git clone -q https://github.com/Philippe-Lawrence/pyBar.git $(PYBAR)
	@sed -i '/set_user_dir/D' $@

$(EPB_SI)/EPB_SI.sty: $(REPO)/EPB_SI.zip
	@unzip -o $< -d $(BDIR)
	@touch $@

$(REPO)/EPB_SI.zip:
	@curl -o $@ http://s2i.pinault-bigeard.com/\
	telechargements/category/15-latex?download=236:epb-si-zip

build/EPB_SI:
	@ln -sf $(BDIR)/EPB_SI $@

.PHONY: clean
clean:
	@$(RM) build/*.aux build/*.log *~

.PHONY: mrproper
mrproper: clean
	@$(RM) build/*
	@rmdir build
	@$(RM) *.pdf
