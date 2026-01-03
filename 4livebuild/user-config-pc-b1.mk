sync:\
 $(CHROOTDIR)/etc\
 $(CHROOTDIR)/usr\
 $(CHROOTDIR)/usr/bin\
 $(CHROOTDIR)/usr/lib\
 ts5000\
 scangearmp2\
 $(SKELDIR)/.config/autostart\
 $(SKELDIR)/.config/autostart/cups.desktop\
 $(CHROOTDIR)/etc/NetworkManager\
 $(CHROOTDIR)/etc/NetworkManager/system-connections\
 $(CHROOTDIR)/etc/NetworkManager/system-connections/Livebox-3705.nmconnection

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
 $(CHROOTDIR)/usr/share/cnijlgmon3\
 $(CHROOTDIR)/usr/share/cnijlgmon3/cnb_cnijlgmon2.res\
 $(CHROOTDIR)/usr/share/cmdtocanonij2\
 $(CHROOTDIR)/usr/share/cmdtocanonij2/autoalign.utl\
 $(CHROOTDIR)/usr/share/cmdtocanonij2/nozzlecheck.utl\
 $(CHROOTDIR)/usr/share/cmdtocanonij2/cleaning.utl

.PHONY: scangearmp2
scangearmp2:\
 $(CHROOTDIR)/usr/bin/scangearmp2\
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
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/libcncpnet2.so.1.2.5\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/libcncpnet30.so.1.0.0\
 $(CHROOTDIR)/usr/share/scangearmp2\
 $(CHROOTDIR)/usr/share/scangearmp2/scangearmp2.glade\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/bjlib\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/bjlib/canon_mfp2_net.ini\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/bjlib/canon_mfp2.conf\
 $(CHROOTDIR)/usr/share/locale/fr/LC_MESSAGES\
 $(CHROOTDIR)/usr/share/locale/fr/LC_MESSAGES/scangearmp2.mo\
 $(SKELDIR)/.local/share/applications/scangearmp2.desktop\

$(SKELDIR)/.local/share/applications/scangearmp2.desktop: $(HOME)/.local/share/applications/scangearmp2.desktop
	@mkdir -p $(SKELDIR)/.local/share/applications
	@cp $< $@

$(SKELDIR)/.config/autostart: $(HOME)/.config/autostart
	@mkdir -p $@
	@cp $</*.desktop $@/

$(SKELDIR)/.config/autostart/cups.desktop: cups.desktop
	@cp $< $@

 $(CHROOTDIR)/etc\
 $(CHROOTDIR)/usr\
 $(CHROOTDIR)/usr/bin\
 $(CHROOTDIR)/usr/lib\
 $(CHROOTDIR)/etc/cups/ppd\
 $(CHROOTDIR)/usr/lib/cups/backend\
 $(CHROOTDIR)/usr/lib/cups/filter\
 $(CHROOTDIR)/usr/lib/bjlib2\
 $(CHROOTDIR)/usr/share/cnijlgmon3\
 $(CHROOTDIR)/usr/share/cmdtocanonij2\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/sane\
 $(CHROOTDIR)/usr/lib/x86_64-linux-gnu/bjlib\
 $(CHROOTDIR)/usr/share/scangearmp2\
 $(CHROOTDIR)/usr/share/locale/fr/LC_MESSAGES\
 $(CHROOTDIR)/etc/NetworkManager\
 $(CHROOTDIR)/etc/NetworkManager/system-connections\
: FORCE
	@mkdir -p $@

$(CHROOTDIR)%: % FORCE
	@test -d $< || sudo $(RSYNC) $< $@
