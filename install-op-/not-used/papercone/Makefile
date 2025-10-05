# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
.PHONY: all
all: papercone.pdf

papercone.pdf: papercone.tex tex_crop.pdf
	@pdflatex --halt-on-error $<

tex_crop.pdf: tex_a4.pdf
	@pdfcrop $< $@

tex_a4.pdf: tex_file.pdf
	@gs -sDEVICE=pdfwrite -sPAPERSIZE=a4 -dFIXEDMEDIA -o $@ $<

tex_file.pdf: papercone.py
	@./$<

.PHONY: clean
clean:
	@$(RM) *.aux *.log tex_*.pdf

.PHONY: mrproper
mrproper: clean
	@$(RM) *.pdf
