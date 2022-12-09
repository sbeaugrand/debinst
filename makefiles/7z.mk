# ---------------------------------------------------------------------------- #
## \file 7z.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/7z.mk
SHRED = shred -u -z
RM = $(SHRED)

.PHONY: zip
zip: $(PROJECT).7z
$(PROJECT).7z: $(ZLIST)
	@rm -f $@
	@7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mhe=on -p $@ $^

.PHONY: unzip
unzip:
	@7z x $(PROJECT).7z

.PHONY: shred
shred: mrproper zip doshred

.PHONY: doshred
doshred: $(ZLIST)
	@$(SHRED) $^
