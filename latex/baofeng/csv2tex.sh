#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file csv2tex.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Source: https://www.la-resilience.fr
# ---------------------------------------------------------------------------- #
src=$1
dst=$2
cat $src | awk -F ',' '
{
    if (NR == 1) { d = $4; o = $5; r = "TSQL"; c = $14; }
    else {
        if ($4 != "") d = $4; else d = "";
        if ($5 != "0.000000") o = substr($5, 0, 4); else o = "";
        if ($6 == "TSQL") r = $7; else r = "";
        if ($14 != "") c = $14;
        else if ($3 == "143.987500") c = "\\textbf{Activités de vol libre}";
        else if ($3 == "145.500000") c = "\\textbf{Canal d'\''appel Radioamateurs}";
        else if ($3 == "145.525000") c = "\\textbf{Canal dégagement Radioamateurs}";
        else if ($3 == "145.550000") c = "\\textbf{Canal dégagement Radioamateurs}";
        else if ($3 == "145.575000") c = "\\textbf{Canal dégagement Radioamateurs}";
        else if ($3 == "146.420000") c = "\\textbf{Non atribué zone 1: Canal dégagement Preppers}";
        else if ($3 == "146.520000") c = "\\textbf{Non atribué zone 1: Canal d'\''appel Survivalistes et Preppers}";
        else if ($3 == "146.550000") c = "\\textbf{Non atribué zone 1: Canal dégagement Survivalistes}";
        else if ($3 == "156.300000") c = "\\textbf{Marine - Canal dégagement Navire à navire}";
        else if ($3 == "156.400000") c = "\\textbf{Marine - Canal dégagement Navire à navire}";
        else if ($3 == "156.800000") c = "\\textbf{Marine - Canal d'\''urgence - Appel de détresse et Sécurité}";
        else if ($3 == "156.625000") c = "\\textbf{Marine - Canal dégagement Navire à navire}";
        else if ($3 == "161.300000") c = "\\textbf{Canal E Secours}";
        else if ($3 == "163.100000") c = "\\textbf{Canal A Secours}";
        else if ($3 == "446.031250" && r == "67.0") c = "Sous-canal d'\''appel Survivalistes et Preppers";
        else if ($3 == "446.031250" && r == "210.7") c = "\\textbf{Canal d'\''appel Survivalistes et Preppers (Sous-canal 3-33)}";
        else if ($3 == "446.031250") c = "\\textbf{Canal d'\''appel Survivalistes et Preppers}";
        else if ($3 == "446.056250") c = "Scoutisme";
        else if ($3 == "446.068750") c = "Relais";
        else if ($3 == "446.081250" && r == "85.4") c = "\\textbf{Sous-canal 7-7 Secours}";
        else if ($3 == "446.081250") c = "Urgences montagne";
        else if ($3 == "446.093750" && r != "") c = "Sous-canal d'\''appel PMR";
        else if ($3 == "446.093750") c = "\\textbf{Canal d'\''appel PMR}";
        else if ($3 == "463.100000") c = "\\textbf{Canal secours UA}";
        else if ($3 == "465.650000") c = "\\textbf{Plan rouge Sécurité Civile}";
        else if ($3 == "465.750000") c = "\\textbf{Plan rouge Sécurité Civile}";
        else if ($3 >= 145.2 && $3 <= 145.2875) c = "Transpondeur satellite";
        else if ($3 >= 145.6 && $3 <= 145.7875) c = "Relais VHF-RA";
        else if ($3 == "156.450000") c = "Marine - Capitainerie des ports de plaisance";
        else if ($3 == "156.500000") c = "Marine - Sémaphore de la Marine Nationale";
        else if ($3 == "156.550000") c = "Marine - Marine Nationale";
        else if ($3 == "156.600000") c = "Marine - Autorités Portuaires";
        else if ($3 == "156.650000") c = "Marine - C.R.O.S.S. et Autorités Portuaires";
        else if ($3 == "156.700000") c = "Marine - Autorités Portuaires";
        else if ($3 == "156.750000") c = "Marine - Surveillance des plages";
        else if ($3 == "156.850000") c = "Marine - Marine Nationale et Autorités Portuaires";
        else if ($3 == "156.375000") c = "Marine - C.R.O.S.S. (coordination du sauvetage en mer)";
        else if ($3 == "156.425000") c = "Marine - C.R.O.S.S. (coordination du sauvetage en mer)";
        else if ($3 == "156.475000") c = "Marine - Marine Nationale";
        else if ($3 == "156.525000") c = "Marine - ASN - Système numérique d'\''appel de détresse";
        else if ($3 == "156.575000") c = "Marine - Marine Nationale";
        else if ($3 == "156.675000") c = "Marine - Marine Nationale et Autorités Portuaires";
        else if ($3 == "156.725000") c = "Marine - Marine Nationale";
        else if ($3 == "156.775000") c = "Marine - Bande de garde - Surveillance du Canal 16";
        else if ($3 == "156.825000") c = "Marine - Surveillance du Canal 17";
        else if ($3 == "156.875000") c = "Marine - Navire à navire";
        else if ($3 >= 430.025 && $3 <= 433.175) c = "Relais UHF";
        else if ($3 >= 446.00625 && $3 <= 446.09375) c = "Professional Mobile Radio";
        else c = "";
    }
    printf "%s&%s&%s&%s&%s&%s&%s\\\\\n",$1,$2,$3,d,o,r,c;
}' >$2
