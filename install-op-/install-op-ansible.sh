# ---------------------------------------------------------------------------- #
## \file install-op-ansible.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
list=`echo $args | cut -d '=' -f 2`
logInfo "ansible role $list"

ANSIBLE_ROLES_PATH=$idir/cicd/makefiles/roles \
ansible-playbook\
 -i $idir/cicd/hosts/localhost/inventory.yml\
 $idir/install-op-/install-op-ansible.yml\
 --ask-become-pass\
 -e list=$list

unset args
