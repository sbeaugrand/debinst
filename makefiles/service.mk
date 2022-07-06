# ---------------------------------------------------------------------------- #
## \file service.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/service.mk

user ?= $(USER)

SRC = $(SERVICE).service
DST = /usr/lib/systemd/system/$(SERVICE).service
define service
 sudo systemctl $1 $(SERVICE).service
endef

.PHONY: install
install: reinstall $(DST)
	@$(call service,enable)

$(DST): $(SRC)
	@sed 's/\$$USER/$(user)/g' $< | sudo tee $@ >/dev/null

.PHONY: uninstall
uninstall: stop
	@$(call service,disable)
	@sudo $(RM) $(DST)

.PHONY: start
start:
	@$(call service,start)

.PHONY: stop
stop:
	@$(call service,stop)

.PHONY: status
status:
	@$(call service,status)
