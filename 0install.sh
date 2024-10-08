#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file 0install.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ "$1" = "--root" ]; then
    if [ `whoami` != "root" ]; then
        if [ -f /etc/sudoers.d/`whoami` ]; then
            sudo su -c "$0 $*"
        else
            su -c "$0 $*"
        fi
        exit $?
    fi
    shift
    [ -z "$user" ] && user=`ls /home | tail -n 1`
else
    if [ "$1" = "--no-root" ]; then
        shift
    fi
    [ -z "$user" ] && user=$USER
    if [ "$user" = "root" ]; then
        user=`ls /home | tail -n 1`
    fi
fi

[ -z "$home" ] && home=/home/$user
[ -z "$data" ] && data=$home/data
[ -z "$repo" ] && repo=$data/install-repo
[ -z "$bdir" ] && bdir=$data/install-build
[ -z "$idir" ] && export idir=$(dirname `readlink -f $0`)
[ -z "$tmpf" ] && tmpf=$XDG_RUNTIME_DIR/debinst.tmp

if ! echo $PATH | grep -q ':\.'; then
    PATH=$PATH:.
fi

# ---------------------------------------------------------------------------- #
## \fn logInfo
# ---------------------------------------------------------------------------- #
logInfo()
{
    echo -ne "\033[32;2m"
    echo " info: $1" | tee -a $log
    echo -ne "\033[0m"
}

# ---------------------------------------------------------------------------- #
## \fn logWarn
# ---------------------------------------------------------------------------- #
logWarn()
{
    echo -ne "\033[33;2m"
    echo " warn: $1" | tee -a $log
    echo -ne "\033[0m"
}

# ---------------------------------------------------------------------------- #
## \fn logError
# ---------------------------------------------------------------------------- #
logError()
{
    echo -ne "\033[31;1m"
    echo " error: $1" | tee -a $log
    echo -ne "\033[0m"
}

# ---------------------------------------------------------------------------- #
## \fn logTodo
# ---------------------------------------------------------------------------- #
logTodo()
{
    echo -ne "\033[33;1m"
    echo " todo: $1" | tee -a $log
    echo -ne "\033[0m"
}

# ---------------------------------------------------------------------------- #
## \fn isDir
# ---------------------------------------------------------------------------- #
isDir()
{
    if [ ! -d "$1" ]; then
        logError "$1 not found"
        return 1
    fi
}

log=/dev/stderr
isDir $data || exit 1
log=$bdir/0install.log
[ -d $bdir ] || (mkdir $bdir && chown $user:$user $bdir)
[ -d $repo ] || (mkdir $repo && chown $user:$user $repo)
[ -d $idir/../repo ] || (mkdir $idir/../repo && chown $user:$user $idir/../repo)
if [ ! -d $home/.local/bin ]; then
    mkdir -p $home/.local/bin
    chown $user:$user $home/.local
    chown $user:$user $home/.local/bin
fi

# ---------------------------------------------------------------------------- #
## \fn logrotate
# ---------------------------------------------------------------------------- #
logrotate()
{
    log=$1
    if [ -f $log ]; then
        if [ -f $log.1 ]; then
            if [ -f $log.2 ]; then
                if [ -f $log.3 ]; then
                    if [ -f $log.4 ]; then
                        mv $log.4 $log.5
                    fi
                    mv $log.3 $log.4
                fi
                mv $log.2 $log.3
            fi
            mv $log.1 $log.2
        fi
        mv $log $log.1
    fi
}
if ! grep -q " / ext4 ro," /proc/mounts; then
    logrotate $log
    cat /dev/null >$log
    chown $user:$user $log
else
    log=/dev/stderr
    logError "Read-only file system, log=/dev/stderr"
fi

# ---------------------------------------------------------------------------- #
## \fn sudoRoot
# ---------------------------------------------------------------------------- #
sudoRoot()
{
    if [ `whoami` = "root" ]; then
        echo -n " sudo: $*" | tee -a $log
    else
        if echo "$*" | grep -q "$tmpf"; then
            logInfo "$tmpf:"
            tail -n 30 $tmpf | sed 's/^/       /'
        fi
        echo -n " sudo: $* (O/n) " | tee -a $log
        read ret
        echo >>$log
        if [ "$ret" = n ]; then
            return 0
        fi
    fi
    if ! eval sudo "$*" >>$log 2>&1; then
        logError "return 1"
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
## \fn pushd
# ---------------------------------------------------------------------------- #
pushd()
{
    echo "cd $1" >>$log
    cd $1 2>>$log
}

# ---------------------------------------------------------------------------- #
## \fn popd
# ---------------------------------------------------------------------------- #
popd()
{
    cd - >/dev/null 2>&1
}

# ---------------------------------------------------------------------------- #
## \fn notGrep
# ---------------------------------------------------------------------------- #
notGrep()
{
    if [ ! -f $2 ]; then
        return 0
    elif ! grep -q "$1" $2; then
        return 0
    else
        logWarn "$1 already in $2"
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
## \fn notFile
# ---------------------------------------------------------------------------- #
notFile()
{
    if [ -f "$1" ]; then
        logWarn "$1 already exists"
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
## \fn notDir
# ---------------------------------------------------------------------------- #
notDir()
{
    if [ -d $1 ]; then
        logWarn "$1 already exists"
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
## \fn notLink
# ---------------------------------------------------------------------------- #
notLink()
{
    if [ -L "$1" ]; then
        logWarn "$1 already exists"
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
## \fn notWhich
# ---------------------------------------------------------------------------- #
notWhich()
{
    if which $1 >/dev/null 2>&1; then
        logWarn "$1 already exists"
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
## \fn isFile
# ---------------------------------------------------------------------------- #
isFile()
{
    if [ ! -f "$1" ]; then
        logError "$1 not found"
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
## \fn isOnline
# ---------------------------------------------------------------------------- #
isOnline()
{
    if grep -q "hypervisor" /proc/cpuinfo; then
        return 0
    fi
    if isFile /proc/net/arp; then
        if ((`cat /proc/net/arp | wc -l` < 2)); then
            return 1
        fi
    fi
}

# ---------------------------------------------------------------------------- #
## \fn download
# ---------------------------------------------------------------------------- #
download()
{
    if ! isOnline; then
        return 0
    fi

    local url=$1
    local file=$2
    if [ -z "$file" ]; then
        file=`basename $url`
    fi

    if notFile $repo/$file; then
        pushd $repo || return 1
        echo curl -Ls $url -o $file >>$log
        curl -Ls $url -o $file || return 1
        chown $user:$user $file
        popd
        echo " download: $repo/$file downloaded" >>$log
    else
        echo " download: $repo/$file already exists" >>$log
    fi
}

# ---------------------------------------------------------------------------- #
## \fn untar
# ---------------------------------------------------------------------------- #
untar()
{
    local file=$1
    if ! isFile $repo/$file; then
        return 1
    fi
    local dir=${file%.*}
    if [ ${dir##*.} = "tar" ]; then
        dir=${dir%.*}
    fi
    local ext=${file##*.}
    local tar="tar xzf"
    if [ $ext = "bz2" ]; then
        tar="tar xjf"
    elif [ $ext = "xz" ]; then
        tar="tar xJf"
    elif [ $ext = "zip" ]; then
        tar="unzip -q"
    elif [ $ext = "tar" ]; then
        tar="tar xf"
    fi

    if [ -n "$2" ]; then
        if notFile $bdir/$2 && notDir $bdir/$2; then
            dir=`dirname $2`
            if [ -n "$3" ]; then
                if notDir $bdir/$3; then
                    mkdir $bdir/$3
                fi
                pushd $bdir/$dir || return 1
            else
                pushd $bdir || return 1
            fi
            $tar $repo/$file
            chown -R $user:$user $bdir/$dir
            popd
        fi
    elif notDir $bdir/$dir; then
        pushd $bdir || return 1
        $tar $repo/$file
        chown -R $user:$user $bdir/$dir
        popd
    fi

    # git checkout
    if [ -d $bdir/$dir/.git ]; then
        pushd $bdir/$dir || return 1
        sudo -u $user git checkout .
        popd
    fi
}

# ---------------------------------------------------------------------------- #
## \fn gitClone
# ---------------------------------------------------------------------------- #
gitClone()
{
    local url=$1
    local name=`basename $url`
    name=${name%.*}
    local opt=
    if [ -n "$2" ]; then
        name="$name-$2"
        opt="-b $2"
    fi
    local file=$repo/$name.tar

    if notDir $bdir/$name; then
        if isOnline; then
            pushd $bdir || return 1
            #sudo SSH_AUTH_SOCK=$SSH_AUTH_SOCK -u $user\
            sudo -u $user --preserve-env=SSH_AUTH_SOCK\
              git clone -q $opt $url $name
            popd
        elif isFile $file; then
            pushd $bdir || return 1
            sudo -u $user tar xf $file
            popd
            pushd $bdir/$name
            sudo -u $user git checkout .
            popd
        else
            return 1
        fi
    fi

    # tar
    if [ ! -f $file ] && isDir $bdir/$name; then
        pushd $bdir || return 1
        tar cf $file $name/.git
        popd
    fi
}

# ---------------------------------------------------------------------------- #
## \fn sourceList
# ---------------------------------------------------------------------------- #
sourceList()
{
    local list="$1"
    for iter in $list; do
        if [ "${iter:0:1}" = "#" ]; then
            continue
        elif [ "${iter:0:1}" = "-" ]; then
            if [ "$iter" = "-su" ]; then
                if [ `whoami` != "root" ]; then
                    logWarn "su -c $0 `echo $* | sed 's/.*-su //'`"
                    su -c "$0 `echo $* | sed 's/.*-su //'`"
                    return
                else
                    continue
                fi
            fi
            if [ -z "$args" ]; then
                args="$iter"
            else
                args="$args $iter"
            fi
            continue
        fi
        echo $iter | tee -a $log
        repoSav=$repo
        if [ ! -f $iter ]; then
            logError "$iter not found"
            if echo $iter | grep -q '\-pr\-'; then
                continue
            else
                exit 1
            fi
        fi
        source $iter
        ret=$?
        repo=$repoSav
        if ((ret != 0)); then
            logError "exit $ret"
            exit $ret
        fi
    done
}

# ---------------------------------------------------------------------------- #
# main
# ---------------------------------------------------------------------------- #
if [ `basename $0` = "0install.sh" ]; then
    if [ -z "$1" ]; then
        installList=`ls install-ob-/*.sh`
    else
        installList=$*
    fi
    sourceList "$installList"
fi
