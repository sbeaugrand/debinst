# ---------------------------------------------------------------------------- #
## \file docker-xc.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
.PHONY: docker-help
docker-help:
	@echo
	@echo "docker build -f makefiles/Dockerfile.armhf -t debian13-armhf ."
	@echo "docker build -f makefiles/Dockerfile.arm64 -t debian13-arm64 ."
	@echo "make docker-xc XC=arm-linux-gnueabihf"
	@echo "make docker-xp XC=arm-linux-gnueabihf"
	@echo "make docker-xc XC=aarch64-linux-gnu"
	@echo "make docker-xp XC=aarch64-linux-gnu"
	@echo

.PHONY: docker-xc
docker-xc:
	@XC=$(XC) makefiles/docker-xc.sh $(PROJECT)

.PHONY: docker-xp
docker-xp:
	@XC=$(XC) makefiles/docker-xc.sh $(PROJECT)\
	 makefiles/docker-xp.sh $(PROJECT)
