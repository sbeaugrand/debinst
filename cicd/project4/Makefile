# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
CPPCHECKINC = --include=build/abstractstubserver.h
XC = arm-linux-gnueabihf
XCVER = 10

include ../makefiles/cmake.mk
include ../makefiles/gitlabci.mk
include ../makefiles/mermaid.mk

.PHONY: doc
doc: classDiagram.svg
classDiagram.svg: README.template.md
	@mmdc -i $< -o $@ -c mmdc.json
	@mv classDiagram-1.svg $@
