# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
.PHONY: runner
runner:
	@forgejo-runner daemon -c build/config.yml

.PHONY: config
config: build build/config.yml
build/config.yml: build/generated.yml
	@patch -p0 -i config.patch
build/generated.yml:
	@forgejo-runner generate-config >$@

build:
	@mkdir $@
