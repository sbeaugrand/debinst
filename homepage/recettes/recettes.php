<?php
if (! empty($_GET['val']))
{
    require_once('bsearch.php');
    exit(0);
}
date_default_timezone_set('Europe/Paris');
session_start();
?>

<html>
<header>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script language="javascript">
var http = null;
if (window.XMLHttpRequest) {
    // Firefox
    http = new XMLHttpRequest();
} else if (window.ActiveXObject) {
    // Internet Explorer
    http = new ActiveXObject("Microsoft.XMLHTTP");
} else {
    alert("Votre navigateur ne supporte pas les objets XMLHTTPRequest.");
}

// -------------------------------------------------------------------------- //
// selectCompletion
// -------------------------------------------------------------------------- //
function selectCompletion() {
    if (http == null) {
        return;
    }
    val = document.completion_form.completion_text.value;
    if (val.length >= 3) {
        http.open("GET", "bsearch.php?val=" + escape(val), true);
        http.onreadystatechange = selectOptions;
        http.send(null);
    } else {
        var sel = document.completion_form.completion_select;
        sel.style.display = 'none';
    }
}

// -------------------------------------------------------------------------- //
// selectOptions
// -------------------------------------------------------------------------- //
function selectOptions() {
    if (http.readyState == 4) {
        options = eval('(' + http.responseText + ')');  // [id1,id2, ...]

        var sel = document.completion_form.completion_select;
        sel.attributes['size'].value = options.length;

        while (sel.options.length > 0) {
            sel.options[0] = null;
        }
        for (i = 0; i < options.length; ++i) {
            sel.options[sel.options.length] =
                new Option(options[i], options[i]);
        }

        if (sel.options.length) {
            sel.style.display = 'block';
        } else {
            sel.style.display = 'none';
        }
    }
}

// -------------------------------------------------------------------------- //
// selectClic
// -------------------------------------------------------------------------- //
function selectClic() {
    var sel = document.completion_form.completion_select ;
    document.completion_form.completion_text.value =
    sel.options[sel.selectedIndex].value ;
    sel.style.display = 'none';
}
</script>
</header>

<?php
// -------------------------------------------------------------------------- //
// supprType
// -------------------------------------------------------------------------- //
function supprType($i)
{
    foreach ($_SESSION['types'] as $nom => $tab) {
        foreach ($tab as $offset => $j) {
            if ($j == $i) {
                unset($_SESSION['types'][$nom][$offset]);
                return;
            }
        }
    }
}

// -------------------------------------------------------------------------- //
// afficheInputs
// -------------------------------------------------------------------------- //
function afficheInputs($i, $recette)
{
    print "<td>\n";
    print $i.') '.$recette;
    print "</td>\n";
    print "<td>\n";
    print '<input type="submit" name="ch['.$i.
        ']" value="Changer" />'."\n";
    print "</td>\n";
    print "<td>\n";
    print '<input type="submit" name="rm['.$i.
        ']" value="Supprimer" />'."\n";
    print "</td>\n";
}

// -------------------------------------------------------------------------- //
// grepPos
// -------------------------------------------------------------------------- //
function grepPos(&$tab, $str)
{
    foreach ($tab as $i => $line) {
        $pos = strpos($line, $str);
        if ($pos !== false) {
            return $i;
        }
    }
    return false;
}

// -------------------------------------------------------------------------- //
// rayons
// -------------------------------------------------------------------------- //
$gRayons =
    array('vin',
          'conserve',
          'épicerie',
          'condiment',
          'cuisine-du-monde',
          'féculent',
          'confiture',
          'gâteau',
          'pâtisserie',
          'charcuterie',
          'fromage',
          'oeuf',
          'lait',
          'fruit',
          'légume',
          'viande',
          'laitage',
          'boulangerie',
          'poisson',
          'surgelé');
$gRayonsKeys = array();
foreach($gRayons as $i => $r) {
    $gRayonsKeys[$r] = $i;
}

// -------------------------------------------------------------------------- //
// cmpRayon
// -------------------------------------------------------------------------- //
function cmpRayon($a, $b)
{
    global $gRayonsKeys;

    return $gRayonsKeys[$a] > $gRayonsKeys[$b];
}

// -------------------------------------------------------------------------- //
// afficheListe
// -------------------------------------------------------------------------- //
function afficheListe()
{
    global $gRayons;

    $ingredients = file('ingredients.txt');
    $liste = array();

    foreach ($_SESSION['recettes'] as $r => $j) {
        if (trim($r) == '') {
            continue;
        }
        $i = grepPos($ingredients, $r);
        if ($i === false) {
            print 'attention: recette non trouvée ('.$r.')<br/>';
            continue;
        }
        ++$i;
        $count = 0;
        while ($ingredients[$i] != "\n") {
            list($label, $valeur) = explode(' ', $ingredients[$i], 2);
            if (in_array($label, $gRayons) == false) {
                print 'attention: rayon non trouvé ('.$label.')<br/>';
            }
            if (isset($liste[$label]) == false) {
                $liste[$label] = array();
            }
            $liste[$label][] = $valeur;
            ++$count;
            ++$i;
        }
        if ($count == 0) {
            print 'attention: recette sans ingrédient ('.$r.')<br/>';
        }
    }
    uksort($liste, 'cmpRayon');
    print '<table>';
    foreach ($liste as $rayon => $tab) {
        print '<tr><td valign="top">';
        print '<b>'.$rayon.'</b>';
        print '</td><td>';
        foreach ($tab as $ingredient) {
            print $ingredient.'<br/>';
        }
        print '</td></tr>';
    }
    print '</table>';
    print '<br/>';
}

// -------------------------------------------------------------------------- //
// main
// -------------------------------------------------------------------------- //
define('POIDS',   0);
define('SAISON',  2);
define('TYPE',    4);
define('NOMBRE',  7);
define('RECETTE', 9);
define('TOTAL',   9);
$MAX = array('le' => 4,
             'fe' => 2,
             'pa' => 2,
             'ta' => 2,
             'oe' => 2,
             'pt' => 2,
             'po' => 1);

if        (isset($_POST['ch']) == true) {
    $ch = key($_POST['ch']);
} else if (isset($_POST['rm']) == true) {
    $rm = key($_POST['rm']);
} else if (isset($_POST['se']) == true) {
    $se = str_replace('\\\'', '\'', $_POST['se']);
    $ns = $_POST['ns'];
} else if (isset($_POST['liste']) == false) {
    unset($_SESSION['recettes']);
    foreach ($MAX as $l => $v) {
        $_SESSION['types'][$l] = array();
    }
}

$liste = file('recettes.txt');
$max = 0;
foreach ($liste as $ligne) {
    $max += substr($ligne, POIDS, 1);
}

$date = date('nd');
     if ($date > 1220) { $saison = 1; }
else if ($date >  920) { $saison = 4; }
else if ($date >  620) { $saison = 3; }
else if ($date >  320) { $saison = 2; }
else                   { $saison = 1; }

print "<body>\n";
print '<form method="post">'."\n";
print "<table>\n";
for ($i = 1; $i <= TOTAL; ++$i) {
    if (((isset($ch) == true && $i != $ch) ||
         (isset($rm) == true && $i != $rm) ||
         (isset($se) == true && $i != $ns) ||
         isset($_POST['liste'])) &&
        isset($_SESSION['recettes']) == true &&
        in_array($i, $_SESSION['recettes']) == true) {
        foreach ($_SESSION['recettes'] as $r => $j) {
            if ($j == $i) {
                print "<tr>\n";
                afficheInputs($i, $r);
                print "</tr>\n";
                if ($i < TOTAL &&
                    in_array($i + 1, $_SESSION['recettes']) == false) {
                    ++$i;
                    print "<tr>\n";
                    print "<td>\n";
                    print $i.') '.$r;
                    print "</td>\n";
                    print "<td>\n";
                    print "</td>\n";
                    print "</tr>\n";
                }
                break;
            }
        }
    } else {
        if (isset($rm) == false) {
            if (isset($se) == false) {
                $rand = mt_rand(1, $max);
                $m = 0;
                foreach ($liste as $ligne) {
                    $m += substr($ligne, POIDS, 1);
                    if ($m >= $rand) {
                        break;
                    }
                }
                $s = substr($ligne, SAISON, 1);
                if ($s != ' ' &&
                    $s != $saison) {
                    --$i;
                    continue;
                }
                $r = substr($ligne, RECETTE, -1);
                if (isset($_SESSION['recettes'][$r]) == true) {
                    --$i;
                    continue;
                }
            } else {
                $pass = false;
                foreach ($liste as $ligne) {
                    $r = substr($ligne, RECETTE, -1);
                    if ($r == $se) {
                        $pass = true;
                        break;
                    }
                }
                if ($pass == false) {
                    print "erreur: '$se' non trouvé<br/>";
                    $ligne = "    po 1 erreur\n";
                    $r = substr($ligne, RECETTE, -1);
                }
                $s = ' ';
            }
            $t = substr($ligne, TYPE, 2);
            if (isset($se) == false &&
                $t != 'po' && empty($_SESSION['types']['po']) == true) {
                --$i;
                continue;
            }
            $n = substr($ligne, NOMBRE, 1);
            if (isset($se) == false &&
                isset($_SESSION['types'][$t]) == true &&
                (count($_SESSION['types'][$t]) == $MAX[$t] ||
                 ($n > 1 && isset($ch) == false && $i < TOTAL &&
                  count($_SESSION['types'][$t]) + 1 == $MAX[$t]))) {
                --$i;
                continue;
            } else {
                supprType($i);
                $_SESSION['types'][$t][] = $i;
                if ($n > 1 &&
                    $i < TOTAL &&
                    isset($ch) == false &&
                    isset($se) == false) {
                    $_SESSION['types'][$t][] = $i + 1;
                }
            }
        } else {
            $r = '';
            for ($j = 0; $j < $i; ++$j) {
                $r .= ' ';
            }
            $s = ' ';
            supprType($i);
        }
        if (isset($_SESSION['recettes']) == true) {
            foreach ($_SESSION['recettes'] as $nom => $j) {
                if ($j == $i) {
                    unset($_SESSION['recettes'][$nom]);
                }
            }
        }
        $_SESSION['recettes'][$r] = $i;
        print "<tr>\n";
        if ($s != ' ') {
            switch ($s) {
            case 1: $r .= ' (hiver)';     break;
            case 2: $r .= ' (printemps)'; break;
            case 3: $r .= ' (été)';       break;
            case 4: $r .= ' (automne)';   break;
            }
        }
        afficheInputs($i, $r);
        print "</tr>\n";
        $n = substr($ligne, NOMBRE, 1);
        if ($n > 1 && isset($ch) == false && $i < TOTAL) {
            ++$i;
            print "<tr>\n";
            print "<td>\n";
            print $i.') '.$r;
            print "</td>\n";
            print "<td>\n";
            print "</td>\n";
            print "</tr>\n";
        }
    }
}
print "</table>\n";
print "</form>\n";

// -------------------------------------------------------------------------- //
// recherche
// -------------------------------------------------------------------------- //
print '<form method="post" name="completion_form">'."\n";
print 'Changer ';
print '<select name="ns">';
for ($i = 1; $i <= TOTAL; ++$i) {
    print '<option value="'.$i.'">'.$i.'</option>'."\n";
}
print '</select>';
print ' par ';
print '<input type="text" name="se" size="60" maxlength="60"'.
    ' onkeyup="selectCompletion();" id="completion_text"/>';
print '<input type="submit" name="comp_ok" value="Ok" />';
print '<select id="completion_select"';
print ' size="1"';
print ' onclick="selectClic();"';
print ' style="display:none;">';
print '</select>';
print '<br/>';
print '</form>';

// -------------------------------------------------------------------------- //
// boutons
// -------------------------------------------------------------------------- //
print "<table><tr><td>\n";
print
'<form method="post">'.
'<input type="submit" value="Recharger" />'.
'</form>'."\n";
print "</td><td>\n";
print
'<form method="post">'.
'<input type="submit" name="liste" value="Liste" />'.
'</form>'."\n";
print "</td></tr></table>\n";
if (isset($_POST['liste'])) {
    afficheListe();
}

// -------------------------------------------------------------------------- //
// statistiques
// -------------------------------------------------------------------------- //
print "<table>\n";
$total = 0;
foreach ($MAX as $l => $v) {
    print "<tr>\n";
    print "<td>\n";
    switch ($l) {
    case 'le': print 'Nombre de légumes         : '; break;
    case 'fe': print 'Nombre de féculents       : '; break;
    case 'pa': print 'Nombre de pates           : '; break;
    case 'ta': print 'Nombre de tartes          : '; break;
    case 'oe': print 'Nombre de d\'oeufs        : '; break;
    case 'pt': print 'Nombre de pommes de terre : '; break;
    case 'po': print 'Nombre de poissons        : '; break;
    }
    print "</td>\n";
    print "<td>\n";
    $n = isset($_SESSION['types'][$l]) == true ?
         count($_SESSION['types'][$l]) : 0;
    $total += $n;
    print $n;
    print " / $v<br/>\n";
    print "</td>\n";
    print "</tr>\n";
}
print '<tr><td>Total</td><td>'.$total.' / '.TOTAL.'</td></tr>';
print "</table>\n";

print "</body>\n";
print "</html>\n";
?>
