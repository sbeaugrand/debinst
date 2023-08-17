<?php
/******************************************************************************!
 * \file testRGB.php
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
require 'randomColor.php';

print '
\documentclass[a4paper]{article}
\pagestyle{empty}
\usepackage{vmargin}
\setmarginsrb{10mm}{10mm}{10mm}{10mm}{0mm}{0mm}{0mm}{0mm}
\usepackage{tikz}
\parindent0mm
\begin{document}
  \tiny
  \begin{tikzpicture}
';

$rc = new RandomColor(0.45);
for ($j = 12; $j >= 0; $j--) {
    for ($i = 0; $i < 8; $i++) {
        $hue = $rc->hue;
        list($r, $g, $b) = $rc->nextRgb(0.24, 0.99);
        $color = 'color'.$i.'y'.$j;
        print '\definecolor{'.$color.'}{rgb}{'.$r.','.$g.','.$b."}\n";
        $x = $i * 2;
        $y = $j * 2;
        print '\fill['.$color.', draw=black,thick,rounded corners=3pt] ('.
            ($x+0).','.($y+0).') -- ('.
            ($x+1).','.($y+0).') -- ('.
            ($x+1).','.($y+1).') -- ('.
            ($x+0).','.($y+1).') -- cycle node[black,below] {'.$hue.
            '};'."\n";
    }
}

print '\end{tikzpicture}'."\n";
print '\newline\newline'."\n";
$rc = new RandomColor(0.0/6);
list($r, $g, $b) = $rc->rgb(1.0, 1.0);
print "Hue 0.0/6 = Rouge ($r $g $b)\\newline\n";
$rc = new RandomColor(1.0/6);
list($r, $g, $b) = $rc->rgb(1.0, 1.0);
print "Hue 1.0/6 = Jaune ($r $g $b)\\newline\n";
$rc = new RandomColor(2.0/6);
list($r, $g, $b) = $rc->rgb(1.0, 1.0);
print "Hue 2.0/6 = Vert ($r $g $b)\\newline\n";
$rc = new RandomColor(3.0/6);
list($r, $g, $b) = $rc->rgb(1.0, 1.0);
print "Hue 3.0/6 = Cyan ($r $g $b)\\newline\n";
$rc = new RandomColor(4.0/6);
list($r, $g, $b) = $rc->rgb(1.0, 1.0);
print "Hue 4.0/6 = Bleu ($r $g $b)\\newline\n";
$rc = new RandomColor(5.0/6);
list($r, $g, $b) = $rc->rgb(1.0, 1.0);
print "Hue 5.0/6 = Violet ($r $g $b)\\newline\n";
print '\end{document}'."\n";
?>
