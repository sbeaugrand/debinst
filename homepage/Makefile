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
all: html png/tux.png favicon.ico http

.PHONY: html
html: $(HTML)

html/%.html: src/%
	src2html.sh $< $@

png/tux.png: /usr/share/icons/silk/16x16/tux.png
	@cp -a $< $@

favicon.ico: png/tux.png
	@icotool -c -o $@ $<

include ../makefiles/http.mk

.PHONY: rsync
rsync: mount dorsync umount

.PHONY: mount
mount:
	@mkdir -p /tmp/$(URL)
	@curlftpfs $(URL) /tmp/$(URL)

.PHONY: dorsync
dorsync:
	@mkdir -p /var/tmp/rsync
	@rsync -r -i --temp-dir=/var/tmp/rsync\
	 --copy-links --size-only --delete\
	 --exclude=php/adresses.txt\
	 --exclude=php/compteur.txt\
	 --exclude='*~'\
	 --exclude='*.swp'\
	 --exclude='*.a'\
	 --exclude='*-pr-*'\
	 --exclude=build\
	 --exclude=debinst/homepage/debinst\
	 --exclude=debinst/homepage/php\
	 --exclude='livret-*.pdf'\
	 --exclude='portrait-*.pdf'\
	 $(PWD)/ /tmp/$(URL)/

.PHONY: umount
umount:
	@fusermount -u /tmp/$(URL)

.PHONY: tgz
tgz:\
 tgz/src.tgz\
 tgz/debinst-dist.tgz\
 tgz/cal.tgz\
 tgz/rdm.tgz\
 tgz/arbreGenealogique.tgz\
 tgz/baofeng.tgz\
 tgz/chebyshev.tgz\
 tgz/schmittTrigger.tgz\
 tgz/cornemuse.tgz\

tgz/src.tgz: $(SRC)
	@tar chvzf $@ $^

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
