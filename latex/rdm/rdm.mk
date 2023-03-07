# ---------------------------------------------------------------------------- #
## \file rdm.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = $(shell basename `readlink -f .`)
PROROOT = ../..
DAT2SVG = ../dat2svg.py
SRCDIR  = $(shell pwd)
PDFOBJECTS = $(patsubst %.dat,build/%.pdf,$(wildcard *.dat))

.PHONY: all
all: $(PROJECT).pdf

include $(PROROOT)/makefiles/repo.mk

$(PROJECT).pdf: $(PROJECT).tex\
 build $(PDFOBJECTS) $(BDIR)/EPB_SI/EPB_SI.sty build/EPB_SI
	@cd build && pdflatex --halt-on-error ../$<
	@mv build/$@ .

build:
	@mkdir $@

$(PDFOBJECTS): build/defo%.pdf: build/defo%.svg
	@rsvg-convert -f pdf -o $@ $<

build/defo%.svg: defo%.dat $(BDIR)/pyBar/pyBar.py $(DAT2SVG)
	@cd $(BDIR)/pyBar && \
	python3 -c '\
	src="'$(SRCDIR)/$<'"; \
	dst="'$(SRCDIR)/$@'"; \
	exec(open("'$(SRCDIR)/$(DAT2SVG)'").read())'

$(BDIR)/pyBar/pyBar.py:
	git clone -q https://github.com/Philippe-Lawrence/pyBar.git $(BDIR)/pyBar
	@sed -i '/set_user_dir/D' $@

$(BDIR)/EPB_SI/EPB_SI.sty: $(REPO)/EPB_SI.zip
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
	@test ! -d build || rmdir build
	@$(RM) *.pdf
