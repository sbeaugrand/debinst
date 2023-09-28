# ---------------------------------------------------------------------------- #
## \file install-op-ansible.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
role=`echo $args | cut -d '=' -f 2`
logInfo "ansible role $role"

ANSIBLE_ROLES_PATH=$idir/cicd/makefiles/roles \
ANSIBLE_GATHERING=explicit \
ansible-playbook\
 -i $idir/cicd/hosts/localhost/inventory.yml\
 $idir/install-op-/install-op-ansible.yml\
 --ask-become-pass\
 -e role=$role

unset args
