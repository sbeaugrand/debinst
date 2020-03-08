<?php
include_once('termes.php');

// -------------------------------------------------------------------------- //
// bsearch
// -------------------------------------------------------------------------- //
function bsearch(&$tab, $a, $b, $s, $l)
{
    while ($a <= $b) {
        $m = ($a + $b) >> 1;

        $c = strcmp($s, substr($tab[$m], 0, $l));
        if ($c == 0) {
            return $m;
        } else if ($c < 0) {
            $b = $m - 1;
        } else {
            $a = $m + 1;
        }
    }

    return -1;
}

// -------------------------------------------------------------------------- //
// Main
// -------------------------------------------------------------------------- //
$completion = array();
$lower  = strtolower($_GET['val']);
$strlen = strlen($lower);
$i = bsearch($termes, 0, count($termes) - 1, $lower, $strlen);
if ($i >= 0) {
    while ($i > 0 && substr($termes[$i - 1], 0, $strlen) == $lower) {
        --$i;
    }
    $f = file('recettes.txt');
    while ($i < sizeof($termes) &&
           substr($termes[$i], 0, $strlen) == $lower) {
        $ligne = intval(substr($termes[$i], -3));
        $completion[] = '"'.substr($f[$ligne], 9, -1).'"';
      //$completion[] = '"'.$ligne.'"';
        ++$i;
    }
}

// Envoi au javascript au format JSON ['valeur1','valeur2', ...]
print '['.join(',', $completion).']';
?>
