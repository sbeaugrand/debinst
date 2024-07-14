# ---------------------------------------------------------------------------- #
## \file Makefile
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
BHOST ?= debian12

.PHONY: all
all:
	@echo "Usage:    make build"
	@echo "          make package"
	@echo "          cd ../hosts/debian12 && make up && cd -"
	@echo "          make rbuild"
	@echo "          cp build/libupm_2.0.0-1.tar.gz build/libupm_2.0.0-1.dsc ../hosts/debian12/.vagrant/"
	@echo "vagrant1> cd ~/pbuilder/bookworm-armhf_result"
	@echo "vagrant1> python3 -m http.server"
	@echo "vagrant2> cd ~/pbuilder/bookworm-armhf_result"
	@echo "vagrant2> dpkg-scanpackages . /dev/null >Packages"
	@echo "vagrant2> pbuilder-dist bookworm armhf update --extrapackages 'libmraa2 libmraa-dev pkg-config' --allow-untrusted --othermirror 'deb [allow-insecure=yes] http://localhost:8000/ ./'"
	@echo "vagrant2> cp /vagrant/.vagrant/libupm_2.0.0-1.* ~/libupm/build/"
	@echo "          make rxpackage OPTS='-e ARCH=armhf'"

include ../makefiles/gitlabci.mk
