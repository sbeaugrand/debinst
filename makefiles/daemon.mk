# ---------------------------------------------------------------------------- #
## \file daemon.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
TARDEPEND += makefiles/daemon.mk

.PHONY: install
install: reinstall
	@sudo cp $(PROJECT)d /etc/init.d/
	@sudo chmod 755 /etc/init.d/$(PROJECT)d
ifeq (/usr/sbin/update-rc.d,$(wildcard /usr/sbin/update-rc.d))
	@sudo /usr/sbin/update-rc.d $(PROJECT)d defaults 25 15
else
	@sudo /sbin/chkconfig $(PROJECT)d on
endif

.PHONY: uninstall
uninstall: stop
ifeq (/usr/sbin/update-rc.d,$(wildcard /usr/sbin/update-rc.d))
	@sudo $(RM) /etc/init.d/$(PROJECT)d
	@sudo /usr/sbin/update-rc.d $(PROJECT)d remove
else
	@sudo /sbin/chkconfig $(PROJECT)d off
	@sudo $(RM) /etc/init.d/$(PROJECT)d
endif

.PHONY: start
start:
	@sudo /etc/init.d/$(PROJECT)d start

.PHONY: stop
stop:
	@sudo /etc/init.d/$(PROJECT)d stop; true

.PHONY: status
status:
	@/etc/init.d/$(PROJECT)d status

.PHONY: kill
kill:
	@/etc/init.d/$(PROJECT)d kill
