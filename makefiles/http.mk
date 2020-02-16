# ---------------------------------------------------------------------------- #
## \file http.mk
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
ifeq ($(INDEX_HTML),)
 ifeq ($(wildcard index.html),index.html)
  INDEX_HTML = index.html
 else
  ifeq ($(wildcard $(PROJECT).html),$(PROJECT).html)
   INDEX_HTML = $(PROJECT).html
  else
   INDEX_HTML = $(PROJECT).php
  endif
 endif
endif

.PHONY: http
http:
	@grep -q "127.0.0.1 $(PROJECT)" /etc/hosts || \
	echo "127.0.0.1 $(PROJECT)" | sudo /usr/bin/tee -a /etc/hosts >/dev/null
	@sudo -b php -S $(PROJECT):8090 -f $(INDEX_HTML) -t $(shell pwd)
	@sleep 1
	@$(BROWSER) http://$(PROJECT):8090/$(INDEX_HTML) &
	@echo
	@echo "Type [enter] to quit "
	@echo
	@read ret
	@sudo kill -2 `ps -C "php -S $(PROJECT)" -o pid=`
