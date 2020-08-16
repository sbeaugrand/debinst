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
readme: README.html
	@lynx $<

%.html: %.md
	@cmark-gfm $< >$@

.PHONY: versions
versions:
	@grep --color "^version=" *.sh */*.sh

.PHONY: not-often-used
not-often-used:
	@ls -1 --color=no install-op-*.sh |\
	 xargs -I {} bash -c "grep -q {} hardware/*.sh || echo {}"

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
	--exclude=*.ged \
	--exclude=*.hex \
	--exclude=*.a \
	\
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
	--exclude=*.ged \
	--exclude=*.hex \
	--exclude=*.a \
	\
	--exclude=*.tgz \
	--exclude=*.ttf \
	--exclude=*.pfb \
	--exclude=*-pr-* \
	--exclude=php \
	$(PROJECT)
