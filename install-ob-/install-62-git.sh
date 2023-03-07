# ---------------------------------------------------------------------------- #
## \file install-62-git.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
gitconfig="git config --global"

if ! $gitconfig --get user.name >/dev/null 2>&1; then
    logTodo "git config --global user.name $user"
fi

if ! $gitconfig --get user.email >/dev/null 2>&1; then
    logTodo "git config --global user.email $user@`hostname`"
fi

if $gitconfig --get alias.alias >/dev/null 2>&1; then
    logWarn "alias already set"
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
