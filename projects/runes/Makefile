# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
define cnc2laser
 @sed -e 's/G00 Z5.000000/S0/' -e 's/.*Penetrate.*/S900/' $< >$@
endef

.PHONY: laser
laser: laser.ngc
laser.ngc: output.ngc
	@$(call cnc2laser)

.PHONY: rect
rect: rect.ngc
rect.ngc: output-rect.ngc
	@$(call cnc2laser)
