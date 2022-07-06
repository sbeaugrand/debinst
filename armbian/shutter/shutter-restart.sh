#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file shutter-restart.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
systemctl is-active shutter-open.timer && systemctl stop shutter-open.timer
systemctl is-active shutter-close.timer && systemctl stop shutter-close.timer
systemctl start shutter
