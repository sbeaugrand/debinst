# ---------------------------------------------------------------------------- #
## \file kibot.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note pip3 wheel --prefer-binary kibot
##       pip3 install --no-compile kibot-*.whl
# ---------------------------------------------------------------------------- #
CONFIG ?= ../../makefiles/kibot.yaml

define kibot
 kibot -c $(CONFIG) $1 | grep -v 'unique warning'
endef

define scale
 inkscape --actions\
  "select-all;transform-scale:$1;fit-canvas-to-selection" -o $2 $3
endef

build:
	@mkdir $@

build/%Schema.pdf: build/%-schema.pdf
	pdfcrop $< $@ >/dev/null

build/%.pdf: build/%.epsi
	epspdf -b $< $@

build/%.epsi: build/%.ps
	ps2epsi $< $@

build/%-schema.pdf\
build/%-light.svg\
build/%-darklight.svg\
: %.kicad_sch $(CONFIG)
	$(call kibot,-e $<)

build/%-B_Cu.ps\
build/%-F_SilkS.ps\
build/%-pcb.pdf\
build/%-pcb.svg\
: %.kicad_pcb $(CONFIG)
	$(call kibot,-b $<)

%.pdf: %.tex
	@echo TEXINPUTS=$(TEXINPUTS)
	@mkdir -p build && cd build && export TEXINPUTS=../$(TEXINPUTS) &&\
	 pdflatex --halt-on-error ../$<
	@mv build/$@ .

livret-%.pdf: %.pdf
	@pdfxup -b -kbb -ow -o $@ $< >/dev/null

portrait-%.pdf: %.pdf
	@pdfjam -q --angle 90 -o $@ $<

landscape-%.pdf: %.pdf
	@pdfjam -q --nup 2x1 --landscape -o $@ $<

.PHONY: check
check:
	@cat *.kicad_pcb | \
	awk '{ if ($$1 == "(segment" && $$3 == $$6 && $$4 == $$7) { print $$0 }; }'

.PHONY: clean
clean:
	@$(RM) *~ *-bak

.PHONY: mrproper
mrproper: clean
	@$(RM) *.pdf *.ps *.svg *-cache*
	@$(RM) -r build
