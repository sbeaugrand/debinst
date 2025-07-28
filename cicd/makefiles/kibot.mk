# ---------------------------------------------------------------------------- #
## \file kibot.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note pip3 wheel --prefer-binary kibot
##       pip3 install --no-compile kibot-*.whl
# ---------------------------------------------------------------------------- #
CONFIG = ../../kicad/kibot.yaml
define kibot
 kibot -c $(CONFIG) $1 | grep -v 'unique warning'
endef

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

%.svg: %.pdf
	@pdftocairo -svg remoteControlSchema.pdf

portrait-%.pdf: %.pdf
	@pdfjam -q --angle 90 -o $@ $<

.PHONY: clean
clean:
	@$(RM) *~ *-bak

.PHONY: mrproper
mrproper: clean
	@$(RM) *.pdf *.ps *.svg
