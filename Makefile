# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
PROJECT = debinst

.SUFFIXES:

.PHONY: all
all:

.PHONY: readme
readme:
	@#cmark-gfm README.md | w3m -T text/html
	@cmark-gfm README.md | lynx -stdin

.PHONY: clean
clean:
	@$(RM) *~
	@find . -name "livret-*.pdf" -exec rm -f {} \;
	@find . -name "portrait-*.pdf" -exec rm -f {} \;

.PHONY: mrproper
mrproper: clean
	@find . -name build -prune -exec rm -fr {} \;
	@find . -name "*.pdf" -exec rm -f {} \;
	@find . -name "*.ttf" -exec rm -f {} \;
	@find . -name "*.pfb" -exec rm -f {} \;

.PHONY: tar
tar:
	@cd .. && tar cvzf $(PROJECT).tgz \
	--exclude=*~ \
	--exclude=.*.swp \
	--exclude=build \
	--exclude=.git \
	--exclude=*.pdf \
	--exclude=*.bck \
	--exclude=*-bak \
	--exclude=*rescue* \
	--exclude=*-cache* \
	--exclude=*.ps \
	--exclude=homepage/tgz \
	$(PROJECT)

.PHONY: dist
dist:
	@cd .. && tar cvzf $(PROJECT)-dist.tgz \
	--exclude=*~ \
	--exclude=.*.swp \
	--exclude=build \
	--exclude=.git \
	--exclude=*.pdf \
	--exclude=*.bck \
	--exclude=*-bak \
	--exclude=*rescue* \
	--exclude=*-cache* \
	--exclude=*.ps \
	--exclude=*.tgz \
	--exclude=*.ttf \
	--exclude=*.pfb \
	--exclude=*.a \
	--exclude=*-pr-* \
	--exclude=php \
	$(PROJECT)
