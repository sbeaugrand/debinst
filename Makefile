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

.PHONY: versions
versions:
	@grep --color "^version=" *.sh */*.sh

.PHONY: updaterepo
updaterepo:
	@grep -r --color=always\
	 --exclude-dir=build\
	 --exclude-dir=build-*\
	 --exclude-dir=armbian\
	 --exclude-dir=mobian\
	 --exclude-dir=raspbian\
	 --exclude-dir=install-pr*\
	 --exclude-dir=not-used\
	 --exclude=*.md\
	 --exclude=Makefile\
	 "gitClone " | tee /dev/stderr |\
	 sed -e 's#.*/##' -e 's/ .*//' -e 's#^#todo: ./4updaterepo.sh #' -e 's/\.git//'

.PHONY: not-used
not-used:
	@ls -1 --color=no install-op-/install-op-*.sh |\
	 xargs -I {} bash -c "grep -q {} hardware/*.sh || test -x {} || echo {}" |\
	 grep -v '\(-src.sh\|codecs\|kivy\)'

.PHONY: pkgs
pkgs:
	@./1buildpackage.sh buildpackage-op-1 dist

.PHONY: iso
iso:
	@./2simplecdd.sh simplecdd-op-1arch64 buildpackage-op-1

.PHONY: iso32
iso32:
	@./2simplecdd.sh simplecdd-op-1arch32 buildpackage-op-1

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
	@cd .. && tar cvzf $(PROJECT).tgz\
	 --exclude=*~\
	 --exclude=.*.swp\
	 --exclude=build\
	 --exclude=build-*\
	 --exclude=*.pdf\
	 --exclude=*.a\
	 --exclude=*.ko\
	 --exclude=*.dtbo\
	 --exclude=*.bck\
	 --exclude=*-bak\
	 --exclude=*rescue*\
	 --exclude=*-cache*\
	 --exclude=*.ps\
	 --exclude=*.nc\
	 --exclude=*.ngc\
	 --exclude=*.hex\
	 --exclude=*.ged\
	 --exclude=*.toc\
	 --exclude=*/amd64/profiles/amd64.packages\
	 --exclude=*/amd64/profiles/amd64.postinst\
	 --exclude=*/amd64/simple-cdd.conf\
	 --exclude=*/i386/profiles/i386.packages\
	 --exclude=*/i386/profiles/i386.postinst\
	 --exclude=*/i386/simple-cdd.conf\
	 --exclude=__pycache__\
	 --exclude=*.egg-info\
	 --exclude=*.7z\
	 --exclude=README.html\
	 --exclude=.vagrant\
	\
	 --exclude=homepage/html\
	 --exclude=homepage/images\
	 --exclude=homepage/tgz\
	 --exclude=.git\
	 $(PROJECT)

.PHONY: dist
dist:
	@cd .. && tar cvzf $(PROJECT)-dist.tgz\
	 --exclude-vcs-ignores\
	 --exclude=.git\
	 $(PROJECT)
