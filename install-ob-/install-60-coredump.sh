# ---------------------------------------------------------------------------- #
## \file install-60-coredump.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if notDir /core; then
    sudoRoot mkdir /core
    sudoRoot chmod 777 /core
fi
