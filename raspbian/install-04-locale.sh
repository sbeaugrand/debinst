# ---------------------------------------------------------------------------- #
## \file install-04-locale.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notGrep "^fr_FR.UTF-8 UTF-8" /etc/locale.gen; then
    echo fr_FR.UTF-8 UTF-8 >>/etc/locale.gen
    locale-gen >>$log 2>&1
fi

if notGrep "LANG=fr_FR.UTF-8" /etc/default/locale; then
    update-locale "LANG=fr_FR.UTF-8" >>$log
    dpkg-reconfigure -f noninteractive locales >>$log 2>&1
fi
