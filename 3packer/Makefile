# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
# ---------------------------------------------------------------------------- #
PROJECT = 3packer

.SUFFIXES:

.PHONY: all
all:

.PHONY: clean
clean:
	@$(RM) *~

.PHONY: tar
tar:
	@cd .. && tar cvzf $(PROJECT).tgz \
	--exclude=*~ \
	--exclude=.*.swp \
	$(PROJECT) $(PROJECT).sh
