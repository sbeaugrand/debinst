# ---------------------------------------------------------------------------- #
## \file install-26-ansible.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
ANSIBLE_ROLES_PATH=$idir/cicd/makefiles/roles \
ansible-playbook\
 -i $idir/cicd/hosts/localhost/inventory.yml\
 $idir/install-ob-/install-*-ansible.yml
