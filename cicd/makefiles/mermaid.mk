# ---------------------------------------------------------------------------- #
## \file mermaid.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
.PHONY: mermaid
mermaid: README.md
README.md: README.template.md
	@mmdc -i $< -o $@ -t dark -b transparent
	@sed -i 's/black/#00ff00/g' README-*.svg
