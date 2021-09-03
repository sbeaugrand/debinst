# ---------------------------------------------------------------------------- #
## \file kicad.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT ?= $(shell basename `readlink -f ..`)

.SUFFIXES:

.PHONY: all
all:
	@echo
	@echo "PROJECT="$(PROJECT)
	@echo
	@echo -n "Usage: make { plot | schema | cuivre | composants | simulation"
	@echo -n " | check | clean "
	@echo $(TARGETS)" }"
	@echo

.PHONY: plot
plot: schema cuivre composants

.PHONY: schema
schema: $(PROJECT)Schema.pdf

$(PROJECT)Schema.pdf: $(PROROOT)/kicad/kicad.lib $(PROJECT).sch
	eeplot -o $@ $^

.PHONY: cuivre
cuivre: $(PROJECT)-B_Cu.pdf

.PHONY: composants
composants: $(PROJECT)-F_SilkS.pdf

%.pdf: %.epsi
	epspdf -b $<

%.epsi: %.ps
	ps2epsi $<

$(PROJECT)-B_Cu.ps $(PROJECT)-F_SilkS.ps: $(PROJECT).kicad_pcb
	kiplot -b $< -c $(PROROOT)/kicad/kiplot.yaml

.PHONY: simulation
simulation: $(PROJECT)Simulation.csv

$(PROJECT)Simulation.csv: $(PROJECT).csv
	$(PROROOT)/makefiles/csvtranspose.sh $< $@

.PHONY: check
check:
	@cat $(PROJECT).kicad_pcb | \
	awk '{ if ($$1 == "(segment" && $$3 == $$6 && $$4 == $$7) { print $$0 }; }'

.PHONY: clean
clean:
	@$(RM) *~ *-bak *-cache.*
