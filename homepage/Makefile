# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
# /usr/share/icons/silk/16x16/tux.png : apt install famfamfam-silk
# ---------------------------------------------------------------------------- #
PROJECT = homepage
BROWSER = firefox
URL = chez.com
SRC = $(wildcard src/*)
HTML = $(addprefix html/,$(addsuffix .html,$(notdir $(SRC))))

.SUFFIXES:

.PHONY: all
all: htmls pdf images/tux.png favicon.ico http

.PHONY: htmls
htmls: html $(HTML)

html:
	@mkdir $@

html/%.html: src/%
	src2html.sh $< $@

.PHONY: pdf
pdf:
	@grep 'pdf/' index.html |\
	 cut -d '"' -f 2 | xargs -I {} ls -l --color {} || true

images/tux.png: /usr/share/icons/silk/16x16/tux.png
	@cp -a $< $@

favicon.ico: images/tux.png
	@icotool -c -o $@ $<

include ../makefiles/http.mk

.PHONY: rsync
rsync: mount dorsync umount

.PHONY: mount
mount: htmls pdf
	@mkdir -p /tmp/$(URL)
	@curlftpfs $(URL) /tmp/$(URL)

.PHONY: dorsync
dorsync:
	@mkdir -p /var/tmp/rsync
	@rsync -r -i --temp-dir=/var/tmp/rsync\
	 --copy-links --size-only --delete\
	 --exclude=php/adresses.txt\
	 --exclude=php/compteur.txt\
	 -f'-s_*~'\
	 -f'-s_*.swp'\
	 -f'-s_*-pr-*'\
	 -f'-s_build'\
	 -f'-s_debinst/homepage/debinst'\
	 -f'-s_debinst/homepage/php'\
	 -f'-s_livret-*.pdf'\
	 -f'-s_portrait-*.pdf'\
	 -f'-s_*.a'\
	 -f'-s_debinst/latex/projects'\
	 -f'-s_debinst/latex/makefiles'\
	 -f'-s_debinst/latex/kicad'\
	 -f'-s_debinst/projects/makefiles'\
	 -f'-s_debinst/homepage/tgz'\
	 -f'-s_debinst/homepage/images'\
	 $(PWD)/ /tmp/$(URL)/

.PHONY: umount
umount:
	@fusermount -u /tmp/$(URL)

.PHONY: tgz
tgz:\
 tgz/debinst-dist.tgz\
 tgz/cal.tgz\
 tgz/rdm.tgz\
 tgz/arbreGenealogique.tgz\
 tgz/baofeng.tgz\
 tgz/chebyshev.tgz\
 tgz/schmittTrigger.tgz\
 tgz/geiger.tgz\
 tgz/cornemuse.tgz\
 tgz/tock.tgz\
 tgz/knotsvg.tgz\

tgz/debinst-dist.tgz: ../../debinst-dist.tgz
	@mv $< $@

../../debinst-dist.tgz:
	@cd .. && make dist

tgz/%.tgz: ../latex/%.tgz
	@mv $< $@

../latex/%.tgz: ../latex/%
	@cd $< && make dist

.PHONY: clean
clean:
	@$(RM) *~

.PHONY: tar
tar:
	@cd .. && tar cvzf $(PROJECT).tgz \
	--exclude=*~ \
	--exclude=.*.swp \
	$(PROJECT)
