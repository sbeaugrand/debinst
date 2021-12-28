MODULES = /usr/lib/modules/$(shell uname -r)

include user-config-pr-b1.mk

sync:\
 $(CHROOTDIR)/etc\
 $(CHROOTDIR)/usr\
 $(CHROOTDIR)/usr/bin\
 $(CHROOTDIR)/usr/lib\
 rtl8821\
 ts5000\
 $(SKELDIR)/.config/lxsession/LXDE/autostart

.PHONY: rtl8821
rtl8821:\
 $(CHROOTDIR)$(MODULES)/updates/dkms\
 $(CHROOTDIR)/etc/modprobe.d\
 $(CHROOTDIR)$(MODULES)/updates/dkms/8821ce.ko\
 $(CHROOTDIR)$(MODULES)/modules.dep\
 $(CHROOTDIR)$(MODULES)/modules.alias\
 $(CHROOTDIR)/etc/modprobe.d/blacklist.conf

#FIXME: Filter failed
.PHONY: ts5000
ts5000:\
 $(CHROOTDIR)/etc/cups/ppd\
 $(CHROOTDIR)/etc/cups/ppd/TS5000LAN.ppd\
 $(CHROOTDIR)/etc/cups/printers.conf\
 $(CHROOTDIR)/usr/lib/libcnbpnet20.so.1.0.0\
 $(CHROOTDIR)/usr/lib/libcnbpcnclapicom2.so.5.0.0\
 $(CHROOTDIR)/usr/lib/libcnnet2.so.1.2.4\
 $(CHROOTDIR)/usr/lib/libcnbpnet30.so.1.0.0\
 $(CHROOTDIR)/usr/lib/cups\
 $(CHROOTDIR)/usr/lib/cups/backend\
 $(CHROOTDIR)/usr/lib/cups/backend/cnijbe2\
 $(CHROOTDIR)/usr/lib/cups/filter\
 $(CHROOTDIR)/usr/lib/cups/filter/rastertocanonij\
 $(CHROOTDIR)/usr/lib/cups/filter/cmdtocanonij2\
 $(CHROOTDIR)/usr/lib/bjlib2\
 $(CHROOTDIR)/usr/lib/bjlib2/cnnet.ini\
 $(CHROOTDIR)/usr/bin/cnijlgmon3\
 $(CHROOTDIR)/usr/bin/tocnpwg\
 $(CHROOTDIR)/usr/bin/tocanonij

$(SKELDIR)/.config/lxsession/LXDE/autostart: FORCE
	@mkdir -p $(SKELDIR)/.config/lxsession/LXDE
	@echo "cp autostart-pr-symlink $@"
	@sed -e 's/SSID/$(SSID)/g' -e 's/"PSK"/"$(PSK)"/' autostart-pr-symlink >$@

 $(CHROOTDIR)/etc\
 $(CHROOTDIR)/usr\
 $(CHROOTDIR)/usr/bin\
 $(CHROOTDIR)/usr/lib\
 $(CHROOTDIR)$(MODULES)/updates/dkms\
 $(CHROOTDIR)/etc/modprobe.d\
 $(CHROOTDIR)/etc/cups/ppd\
 $(CHROOTDIR)/usr/lib/cups/backend\
 $(CHROOTDIR)/usr/lib/cups/filter\
 $(CHROOTDIR)/usr/lib/bjlib2\
: FORCE
	@mkdir -p $@

$(CHROOTDIR)%: % FORCE
	@test -d $< || sudo $(RSYNC) $< $@
