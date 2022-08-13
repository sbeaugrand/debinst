#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file 0install.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ "$1" = "--root" ]; then
    if [ `whoami` != "root" ]; then
        su -c "$0 $*"
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
# isDir
# ---------------------------------------------------------------------------- #
isDir()
{
    if [ -d "$1" ]; then
        return 0
    else
        echo " error: $1 not found" | tee -a $log
        return 1
    fi
}

log=/dev/stderr
isDir $data || exit 1
log=$bdir/0install.log
[ -d $bdir ] || mkdir $bdir && chown $user.$user $bdir
[ -d $repo ] || mkdir $repo && chown $user.$user $repo
[ -d $idir/../repo ] || mkdir $idir/../repo && chown $user.$user $idir/../repo
if [ ! -d $home/.local/bin ]; then
    mkdir -p $home/.local/bin
    chown $user.$user $home/.local
    chown $user.$user $home/.local/bin
fi

# ---------------------------------------------------------------------------- #
# logrotate
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
if ! grep " / ext4 ro," /proc/mounts; then
    logrotate $log
    cat /dev/null >$log
    chown $user.$user $log
else
    log=/dev/stderr
fi

# ---------------------------------------------------------------------------- #
# sudoRoot
# ---------------------------------------------------------------------------- #
sudoRoot()
{
    if [ `whoami` = "root" ]; then
        echo -n " sudo: $*" | tee -a $log
    else
        if echo "$*" | grep -q "$tmpf"; then
            echo " info: $tmpf:"
            sed 's/^/       /' $tmpf
        fi
        echo -n " sudo: $* (O/n) " | tee -a $log
        read ret
        if [ "$ret" = n ]; then
            return 0
        fi
    fi
    if ! eval sudo "$*" >>$log 2>&1; then
        echo " error: return 1" | tee -a $log
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# pushd
# ---------------------------------------------------------------------------- #
pushd()
{
    echo "cd $1" >>$log
    cd $1 2>>$log
}

# ---------------------------------------------------------------------------- #
# popd
# ---------------------------------------------------------------------------- #
popd()
{
    cd - >/dev/null 2>&1
}

# ---------------------------------------------------------------------------- #
# notGrep
# ---------------------------------------------------------------------------- #
notGrep()
{
    if [ ! -f $2 ]; then
        return 0
    elif ! grep -q "$1" $2; then
        return 0
    else
        echo " warn: $1 already in $2" | tee -a $log
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# notFile
# ---------------------------------------------------------------------------- #
notFile()
{
    if [ ! -f "$1" ]; then
        return 0
    else
        echo " warn: $1 already exists" | tee -a $log
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# notDir
# ---------------------------------------------------------------------------- #
notDir()
{
    if [ ! -d $1 ]; then
        return 0
    else
        echo " warn: $1 already exists" | tee -a $log
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# notLink
# ---------------------------------------------------------------------------- #
notLink()
{
    if [ ! -L "$1" ]; then
        return 0
    else
        echo " warn: $1 already exists" | tee -a $log
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# notWhich
# ---------------------------------------------------------------------------- #
notWhich()
{
    if ! which $1 >/dev/null 2>&1; then
        return 0
    else
        echo " warn: $1 already exists" | tee -a $log
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# isFile
# ---------------------------------------------------------------------------- #
isFile()
{
    if [ -f "$1" ]; then
        return 0
    else
        echo " error: $1 not found" | tee -a $log
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# isOnline
# ---------------------------------------------------------------------------- #
isOnline()
{
    if isFile /proc/net/arp; then
        if ((`cat /proc/net/arp | wc -l` < 2)); then
            return 1
        fi
    fi
    return 0
}

# ---------------------------------------------------------------------------- #
# download
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
        chown $user.$user $file
        popd
        echo " download: $repo/$file downloaded" >>$log
    else
        echo " download: $repo/$file already exists" >>$log
    fi
    return 0
}

# ---------------------------------------------------------------------------- #
# untar
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
        if notFile $bdir/$2; then
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
            chown -R $user.$user $bdir/$dir
            popd
        fi
    elif notDir $bdir/$dir; then
        pushd $bdir || return 1
        $tar $repo/$file
        chown -R $user.$user $bdir/$dir
        popd
    fi

    # git checkout
    if [ -d $bdir/$dir/.git ]; then
        pushd $bdir/$dir || return 1
        sudo -u $user git checkout .
        popd
    fi
    return 0
}

# ---------------------------------------------------------------------------- #
# gitClone
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
    return 0
}

# ---------------------------------------------------------------------------- #
# install
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
                    echo " warn: su -c $0 `echo $* | sed 's/.*-su //'`"
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
            echo "error: $iter not found"
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
            echo "exit $ret"
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
