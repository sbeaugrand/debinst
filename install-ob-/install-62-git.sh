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
