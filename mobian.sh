#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file mobian.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
project=`basename $0 .sh`
if [ `whoami` = "root" ]; then
    echo "Usage: [user=mobian] [host=mobian] ./$project.sh"
    exit 1
fi
user=${user:-mobian}
host=${host:-mobian}
uri=$user@$host
echo "user = $user"
echo "host = $host"

[ -z "$data" ] && data=$HOME/data
[ -z "$repo" ] && repo=$data/install-repo
[ -z "$bdir" ] && bdir=$data/install-build

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
# notGrep
# ---------------------------------------------------------------------------- #
notGrep()
{
    if ! grep -q "$1" $2; then
        return 0
    else
        echo " warn: $1 already in $2" | tee -a $log
        return 1
    fi
}

# ---------------------------------------------------------------------------- #
# ssh
# ---------------------------------------------------------------------------- #
file=~/.profile
if isFile ~/.ssh/id_rsa.pub && notGrep "keychain" $file; then
    echo 'source ~/.keychain/*-sh' >>$file
fi
file=install-pr-/install-pr-authorized_keys
if ! isFile $file; then
    exit 1
fi
ssh $uri "test -d .ssh || mkdir .ssh && chmod 700 .ssh"
rsync -i --no-times --checksum $file $uri:/home/$user/.ssh/authorized_keys

# ---------------------------------------------------------------------------- #
# PasswordAuthentication=no
# ---------------------------------------------------------------------------- #
if ! ssh -o PasswordAuthentication=no $uri true; then
    exit 1
fi
ssh -t $uri "
grep -q '^PasswordAuthentication no' /etc/ssh/sshd_config ||\
 sudo sed -i 's/.*PasswordAuthentication yes/PasswordAuthentication no/'\
 /etc/ssh/sshd_config"

# ---------------------------------------------------------------------------- #
# install
# ---------------------------------------------------------------------------- #
ssh $uri "test -d install/debinst || mkdir -p install/debinst"
rsync -rli --delete --no-times --checksum --exclude=__pycache__\
 ~/install/debinst/0install.sh\
 ~/install/debinst/$project\
 ~/install/debinst/install-op-/install-op-lingot.sh\
 $uri:/home/$user/install/debinst/

# ---------------------------------------------------------------------------- #
# data
# ---------------------------------------------------------------------------- #
ssh $uri "test -d data/install-build || mkdir -p data/install-build"
ssh $uri "test -d data/install-repo || mkdir -p data/install-repo"

dir=/usr/share/games/supertuxkart/data/sfx
file=start_race.ogg
if isFile $dir/$file; then
    if notFile $bdir/$file; then
        sox $dir/pre_start_race.ogg $dir/pre_start_race.ogg $dir/start_race.ogg $bdir/$file.wav
        ffmpeg -loglevel error -i $bdir/$file.wav -c:a libvorbis $bdir/$file
    fi
    if isFile $bdir/$file; then
        rsync -i --no-times --checksum\
         $bdir/$file $uri:/home/$user/data/install-build/$file
    fi
fi

url=http://www.yalsro.ovh/~drfred/musique/music/sagas_audio/donjon_de_naheulbeuk/bonus
file=NBK-Sonnerie01-casonne.mp3
if notFile $repo/$file; then
    curl -s $url/$file -o $repo/$file
fi
if notFile $bdir/$file.oga; then
    ffmpeg -loglevel error -i $repo/$file -c:a libvorbis $bdir/$file.oga
fi
if isFile $bdir/$file.oga; then
    rsync -i --no-times --checksum\
     $bdir/$file.oga $uri:/home/$user/data/install-build/$file.oga
fi
