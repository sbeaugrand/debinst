<?php
$f = file('recettes.tmp');
foreach ($f as $i => $v) {
    $t = explode(' ', trim($v));
    foreach ($t as $v) {
        if (strlen($v) < 3 || $v == 'aux') {
            continue;
        }
        $ligne = strtolower($v).sprintf('%03d', $i);
        $s[]   = strtr(utf8_decode($ligne),
                       utf8_decode('àâéèÉô'), 'aaeeeo');
    }
}
sort($s);
printf('<?php $termes = array('."\n");
foreach($s as $v) {
    printf("'%s',\n", $v);
}
printf("); ?>\n"); 
?>
