# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note make S=1w
# ---------------------------------------------------------------------------- #
S ?= 1d

.PHONY: all
all: allow deny
	@./check.sh $(S)

allow: allow.in
	@sed -e 's/ #.*//' -e 's/\./\\./g' $< >$@

deny: /etc/dnscrypt-proxy/blocked-names.txt
	@sed -e 's/\./\\./g' -e 's/\*/.*/g' $< >$@
