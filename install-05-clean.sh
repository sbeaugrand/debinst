# ---------------------------------------------------------------------------- #
## \file install-05-clean.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
if which clipit >/dev/null 2>&1; then
    kill -9 `ps -C "clipit" -o pid=`
    apt-get -y --auto-remove purge clipit >>$log
fi

pushd $home || return 1
if [ -d public_html ]; then
    rm public_html/.directory
    rmdir public_html
fi
for d in Documents Images Modèles Musique Public Téléchargements Vidéos; do
    if [ -d $d ]; then
        rmdir $d
    fi
done
popd
