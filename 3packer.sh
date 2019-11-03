# ---------------------------------------------------------------------------- #
## \file 3packer.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ -z "$1" ]; then
    echo "Usage: `basename $0` <iso>"
fi
iso=$1

cp -n $HOME/.ssh/id_pem_rsa.pub 3packer/authorized_keys

#export PACKER_LOG=1

PATH="$PATH":.\
 packer build\
 -var "iso=$1"\
 3packer/packer.json
