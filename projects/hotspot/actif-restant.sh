#!/bin/sh
# ---------------------------------------------------------------------------- #
## \file actif-restant.sh
## \brief Temps d'usage restant d'apres les requetes actif-{t}.example.com.
##
## L'application "actif" emet une requete DNS actif-HHmmss.example.com a chaque
## minute d'utilisation du telephone. tcpdump-dns.sh les journalise (elles
## n'apparaissent QUE si tcpdump-dns.service tourne).
##
## Ce script, a partir de 18h00, compte les minutes distinctes contenant au
## moins une de ces requetes, puis renvoie le temps restant :
##     restant = budget - minutes_comptees   (borne a 0)
## Les minutes sans requete (trous, service arrete) ne sont ni comptees ni une
## rupture : seules les minutes d'usage consomment le budget.
## (Prevu pour une seule soiree : pas de distinction de jour.)
##
## Usage :
##     actif-restant.sh [-v] <budget_minutes> [journal]
##   - budget_minutes : budget alloue, en minutes (ex. 90)
##   - journal        : fichier a lire (ex. yesterday.log) ; a defaut, le
##                      journal systemd du jour est lu via journalctl.
##   - -v             : detail sur stderr (minutes comptees)
##
## Variable d'environnement :
##   START_HOUR  heure de debut du decompte (defaut 18)
## ---------------------------------------------------------------------------- #

set -eu

verbose=0
if [ "${1:-}" = "-v" ]; then verbose=1; shift; fi

if [ $# -lt 1 ]; then
    echo "usage: $0 [-v] <budget_minutes> [journal]" >&2
    exit 2
fi

budget=$1
case $budget in
    ''|*[!0-9]*) echo "$0: budget invalide: '$budget'" >&2; exit 2;;
esac

start_hour=${START_HOUR:-18}

# Source des lignes : fichier donne, sinon le journal du service pour aujourd'hui.
if [ $# -ge 2 ]; then
    src() { cat -- "$1"; }
else
    src() { journalctl -u tcpdump-dns.service --since today --no-pager; }
fi

src "${2:-}" | awk -v budget="$budget" -v start_hour="$start_hour" -v verbose="$verbose" '
BEGIN { count = 0 }
# Lignes attendues : "nov. 20 19:40:47 host tcpdump-dns.sh[pid]: Nom  actif-...".
# On ne compte que les requetes actif-{chiffres}.example.com.
$0 ~ /actif-[0-9]+\.example\.com/ {
    n = split($3, t, ":")      # $3 = HH:MM:SS
    if (n < 2) next
    hh = t[1] + 0
    mm = t[2] + 0
    if (hh < start_hour) next  # avant l heure de debut : ne compte pas

    key = sprintf("%02d:%02d", hh, mm)   # une minute comptee une seule fois
    if (!(key in seen)) {
        seen[key] = 1
        count++
        if (verbose) print "  compte " key > "/dev/stderr"
    }
}
END {
    rem = budget - count
    if (rem < 0) rem = 0
    if (verbose)
        printf "minutes comptees = %d, budget = %d, restant = %d\n", \
               count, budget, rem > "/dev/stderr"
    print rem
}
'
