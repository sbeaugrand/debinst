# ---------------------------------------------------------------------------- #
## \file kibot.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note pip3 wheel --prefer-binary kibot
##       pip3 install --no-compile kibot-*.whl
# ---------------------------------------------------------------------------- #
CONFIG = ../../makefiles/kibot.yaml

define kibot
 kibot -c $(CONFIG) $1 | grep -v 'unique warning'
endef

define scale
 inkscape --actions\
  "select-all;transform-scale:$1;fit-canvas-to-selection" -o $2 $3
endef

%Schema.pdf: %-schema.pdf
	pdfcrop $< $@ >/dev/null

%.pdf: %.epsi
	epspdf -b $<

%.epsi: %.ps
	ps2epsi $<

%-schema.pdf %-light.svg %-dark.svg: %.kicad_sch $(CONFIG)
	$(call kibot,-e $<)

%-B_Cu.ps %-F_SilkS.ps %-pcb.pdf %-pcb.svg: %.kicad_pcb $(CONFIG)
	$(call kibot,-b $<)

portrait-%.pdf: %.pdf
	@pdfjam -q --angle 90 -o $@ $<

.PHONY: clean
clean:
	@$(RM) *~ *-bak

.PHONY: mrproper
mrproper: clean
	@$(RM) *.pdf *.ps *.svg
