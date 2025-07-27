# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
# ---------------------------------------------------------------------------- #
CONFIG = $(PROROOT)/kicad/kibot.yaml
define kibot
 kibot -c $(CONFIG) $1 | grep -v 'unique warning'
endef

.PHONY: all
all:\
 $(PROJECT)Schema.pdf\
 $(PROJECT)-B_Cu.pdf\
 $(PROJECT)-F_SilkS.pdf\
 $(PROJECT)-pcb.pdf

%Schema.pdf: %-schema.pdf
	pdfcrop $< $@

%.pdf: %.epsi
	epspdf -b $<

%.epsi: %.ps
	ps2epsi $<

%-schema.pdf: %.kicad_sch $(CONFIG)
	$(call kibot,-e $<)

%-B_Cu.ps: %.kicad_pcb $(CONFIG)
	$(call kibot,-b $<)

%-F_SilkS.ps: %.kicad_pcb $(CONFIG)
	$(call kibot,-b $<)

%-pcb.pdf: %.kicad_pcb $(CONFIG)
	$(call kibot,-b $<)

.PHONY: clean
clean:
	@$(RM) *~ *-bak

.PHONY: mrproper
mrproper: clean
	@$(RM) *.pdf
