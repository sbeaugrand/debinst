# ---------------------------------------------------------------------------- #
## \file install-62-git.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
gitconfig="sudo -u $user git config --global"

if ! $gitconfig --get user.name >/dev/null 2>&1; then
    echo
    echo Todo :
    echo git config --global user.name $user
    echo
fi

if ! $gitconfig --get user.email >/dev/null 2>&1; then
    echo
    echo Todo :
    echo git config --global user.email $user@`hostname`
    echo
fi

if $gitconfig --get alias.alias >/dev/null 2>&1; then
    echo " warn: alias already set" | tee -a $log
    return 0
fi

$gitconfig rebase.autosquash true
$gitconfig core.editor "vim"
$gitconfig alias.st 'status'
$gitconfig alias.gr 'log --graph'
$gitconfig alias.br 'branch -a'
$gitconfig alias.rprune 'remote -v prune origin'
$gitconfig alias.rmerge 'pull origin'
$gitconfig alias.diffv 'difftool -y --extcmd="vimdiff"'
$gitconfig alias.diffw 'diff --color-words'
$gitconfig alias.diffy 'difftool -y --extcmd="colordiff -ydw -W$(tput cols)"'
$gitconfig alias.alias '! git config --global --get-regexp alias. | grep -v alias.alias'
