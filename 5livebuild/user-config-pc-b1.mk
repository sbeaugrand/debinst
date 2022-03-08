KERNEL = $(shell uname -r)
MODULES = /usr/lib/modules/$(KERNEL)

# SSID WPAK
include user-config-pr-b1.mk

sync:\
 $(CHROOTDIR)/etc\
 $(CHROOTDIR)/usr\
 $(CHROOTDIR)/usr/bin\
 $(CHROOTDIR)/usr/lib\
 rtl8821\
 ts5000\
 scangearmp2\
 $(SKELDIR)/.config/lxsession/LXDE/autostart

.PHONY: rtl8821
rtl8821:\
 $(CHROOTDIR)$(MODULES)/updates/dkms\
 $(CHROOTDIR)/etc/modprobe.d\
 $(CHROOTDIR)$(MODULES)/updates/dkms/8821ce.ko\
 $(CHROOTDIR)$(MODULES)/modules.dep\
 $(CHROOTDIR)$(MODULES)/modules.alias\
 $(CHROOTDIR)/etc/modprobe.d/blacklist.conf

.PHONY: ts5000
ts5000:\
 $(CHROOTDIR)/etc/cups/ppd\
 $(CHROOTDIR)/etc/cups/ppd/TS5000LAN.ppd\
 $(CHROOTDIR)/etc/cups/printers.conf\
 $(CHROOTDIR)/usr/lib/libcnbpnet20.so.1.0.0\
 $(CHROOTDIR)/usr/lib/libcnbpcnclapicom2.so.5.0.0\
 $(CHROOTDIR)/usr/lib/libcnnet2.so.1.2.4\
 $(CHROOTDIR)/usr/lib/libcnbpnet30.so.1.0.0\
 $(CHROOTDIR)/usr/lib/libcnbpnet20.so\
 $(CHROOTDIR)/usr/lib/libcnbpcnclapicom2.so\
 $(CHROOTDIR)/usr/lib/libcnnet2.so\
 $(CHROOTDIR)/usr/lib/libcnbpnet30.so\
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
 $(CHROOTDIR)/usr/bin/tocanonij\
 $(CHROOTDIR)/usr/share\
 $(CHROOTDIR)/usr/share/cnijlgmon3\
 $(CHROOTDIR)/usr/share/cnijlgmon3/cnb_cnijlgmon2.res\
 $(CHROOTDIR)/usr/share/cmdtocanonij2\
 $(CHROOTDIR)/usr/share/cmdtocanonij2/autoalign.utl\
 $(CHROOTDIR)/usr/share/cmdtocanonij2/nozzlecheck.utl\
 $(CHROOTDIR)/usr/share/cmdtocanonij2/cleaning.utl

# wip
.PHONY: scangearmp2
scangearmp2:\
 $(CHROOTDIR)/usr/bin/scangearmp2\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/sane\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/sane/libsane-canon_pixma.so.1.0.0\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/sane/libsane-canon_pixma.so.1\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/sane/libsane-canon_pixma.so\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/libcncpmslld2.so\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/libcncpnet20.so\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/libcncpnet30.so\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/libcncpmslld2.so.3.0.0\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/libcncpnet2.so\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/libcncpnet20.so.1.0.0\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/libcncpnet2.so.1.2.4\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/libcncpnet30.so.1.0.0\
 $(CHROOTDIR)/usr/share/scangearmp2/scangearmp2.glade\
 $(SKELDIR)/.local/share/applications/scangearmp2.desktop\

$(SKELDIR)/.local/share/applications/scangearmp2.desktop: $(HOME)/.local/share/applications/scangearmp2.desktop
	@mkdir -p $(SKELDIR)/.local/share/applications
	@cp $< $@

$(SKELDIR)/.config/lxsession/LXDE/autostart: FORCE
	@mkdir -p $(SKELDIR)/.config/lxsession/LXDE
	@echo "cp autostart-pr-symlink $@"
	@sed\
	 -e 's/SSID/$(SSID)/g'\
	 -e 's/WPAK/$(WPAK)/'\
	 -e 's/KERNEL/$(KERNEL)/'\
	 autostart-pr-symlink >$@

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
 $(CHROOTDIR)/usr/share\
 $(CHROOTDIR)/usr/share/cnijlgmon3\
 $(CHROOTDIR)/usr/share/cmdtocanonij2\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/sane\
 $(CHROOTDIR)/usr/share/scangearmp2\
: FORCE
	@mkdir -p $@

$(CHROOTDIR)%: % FORCE
	@test -d $< || sudo $(RSYNC) $< $@
