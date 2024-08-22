# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
CPPCHECKINC = --include=build/abstractstubserver.h
XC = arm-linux-gnueabihf
XCVER = 10
URL = http://localhost:8383

include ../makefiles/cmake.mk
include ../makefiles/gitlabci.mk
include ../makefiles/mermaid.mk

build/abstractstubserver.h: spec.json
	@cd build && jsonrpcstub ../spec.json --cpp-server=AbstractStubServer

define send
 curl -d '{"jsonrpc":"2.0","method":"$1","id":1}' $(URL)
endef

define notify
 curl -d '{"jsonrpc":"2.0","method":"$1"}' $(URL)
endef

.PHONY: status object
status object:
	@$(call send,$@)

.PHONY: quit
quit:
	@$(call notify,$@); true

.PHONY: mermaid
mermaid: README-0.md
README-0.md: README.md
	${call mermaid,$<,$@}

.PHONY: resize
resize: README-0-1.svg README-0-2.svg
README-0-1.svg README-0-2.svg: FORCE
	$(call resize,$@)

.PHONY: doc
doc: classDiagram.svg
classDiagram.svg: README.template.md
	@mmdc -i $< -o $@ -c mmdc.json
	@mv classDiagram-1.svg $@
