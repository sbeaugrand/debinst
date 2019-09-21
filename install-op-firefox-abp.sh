# ---------------------------------------------------------------------------- #
## \file install-op-firefox-abp.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note https://adblockplus.org/
# ---------------------------------------------------------------------------- #
#file=adblockplusfirefox.xpi
#download https://update.adblockplus.org/latest/$file || return 1
#sudo -u $user firefox $repo/$file

sudo -u $user firefox https://eyeo.to/adblockplus/firefox_install/
