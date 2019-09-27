#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file 0install.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if [ `whoami` != "root" ]; then
    su -c "$0 $*"
    exit $?
fi
PATH=$PATH:.

[ -z "$user" ] && user=`ls /home | tail -n 1`
[ -z "$home" ] && home=/home/$user
[ -z "$data" ] && data=$home/data
[ -z "$repo" ] && repo=$data/install-repo
[ -z "$bdir" ] && bdir=$data/install-build
[ -z "$idir" ] && export idir=`pwd`

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
[ -d $repo ] || sudo -u $user mkdir $repo
[ -d $bdir ] || sudo -u $user mkdir $bdir

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
logrotate $log
cat /dev/null >$log

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
    if ! grep -q "$1" $2; then
        return 0
    else
        echo " warn: $1 already in $2"
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
    return 0
}

# ---------------------------------------------------------------------------- #
# gitClone
# ---------------------------------------------------------------------------- #
gitClone()
{
    url=$1
    name=`basename $url`
    name=${name%.*}

    if notDir $bdir/$name; then
        if isOnline; then
            pushd $bdir || return 1
            sudo -u $user git clone -q $url
            popd
        elif isFile $repo/$name.tgz; then
            pushd $bdir || return 1
            tar xzf $repo/$name.tgz
            popd
            pushd $bdir/$name
            git checkout .
            popd
        fi
    fi

    if [ ! -f $repo/$name.tgz ] && isDir $bdir/$name; then
        pushd $bdir || return 1
        tar czf $repo/$name.tgz $name/.git
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
            args="$args $iter"
            continue
        fi
        echo $iter | tee -a $log
        repoSav=$repo
        source $iter
        ret=$?
        repo=$repoSav
        if ((ret != 0)); then
            echo "return $ret"
            exit $ret
        fi
    done
}

if [ -z "$1" ]; then
    installList=`ls install-[0-9][0-9][^0-9]*.sh`
else
    installList=$*
fi
sourceList "$installList"
