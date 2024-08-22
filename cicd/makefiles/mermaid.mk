# ---------------------------------------------------------------------------- #
## \file mermaid.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
define mermaid
 @mmdc -i $1 -o $2 -t dark -b transparent
 @sed -i 's/black/#00ff00/g' README-*.svg
endef

define resize
 @sed 's/.*viewBox="\([^"]*\)".*/\1/' $1 |\
  awk '{ print "s/"$$0"/"$$1-100" "$$2" "$$3+200" "$$4"/" }' |\
  awk '{ system("sed -i \""$$0"\" '$1'") }'
endef
