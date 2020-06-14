<?php
/******************************************************************************!
 * \file gramps2tex.php
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
if ($argc != 2 || $argv[1] != 'tests') {
    if ($argc != 6) {
        print "Usage: $argv[0] <export.csv> <1|2> <lmax>";
        print " <sibiling-distance> <level-distance>\n";
        exit(1);
    }
    $filename = $argv[1];
    $parent = $argv[2];
    $lmax = $argv[3];
    $below = $argv[4] / 4;
    $left = $argv[5] / 2 + 2;
    $right = $argv[5] / 2 - 5;
}
const GENRE_M = 1;
const GENRE_F = 2;
const LIEU = 1;
const INDIVIDU = 2;
const MARIAGE = 3;
const FAMILLE = 4;

if (! function_exists('array_key_first')) {
    function array_key_first(array $arr) {
        foreach ($arr as $key => $unused) {
            return $key;
        }
        return NULL;
    }
}

require 'randomColor.php';

/******************************************************************************!
 * \class Departement
 ******************************************************************************/
class Departement
{
    var $name;
    var $color;

    /**************************************************************************!
     * \fn construct
     **************************************************************************/
    function __construct($d) {
        $this->name = $d;
        $this->color = '';
    }
}

/******************************************************************************!
 * \class DepartementList
 ******************************************************************************/
class DepartementList
{
    var $randomColor;
    var $deparList;
    var $colorList;
    var $colorIter;

    /**************************************************************************!
     * \fn construct
     **************************************************************************/
    function __construct() {
        $this->randomColor = new RandomColor(0.5);
        $this->colorIter = 0;
    }
    /**************************************************************************!
     * \fn add
     **************************************************************************/
    public function add($d) {
        $this->deparList[] = new Departement($d);
        $this->colorList[] = $this->addColor($d);
    }
    /**************************************************************************!
     * \fn getColor
     **************************************************************************/
    public function getColor($d) {
        foreach ($this->deparList as $dep) {
            if ($dep->name != $d) {
                continue;
            }
            if (empty($dep->color)) {
                $dep->color = $this->colorList[$this->colorIter];
                $this->colorIter++;
            }
            return $dep->color;
        }
    }
    /**************************************************************************!
     * \fn addColor
     **************************************************************************/
    private function addColor($d) {
        $c = $this->colorName($d);
        list($r, $g, $b) = $this->randomColor->nextRgb(0.24, 0.99);
        print '\definecolor{'.$c.GENRE_M.'}{rgb}{'.$r.','.$g.','.$b."}\n";
        list($r, $g, $b) = $this->randomColor->rgb(0.12, 0.99);
        print '\definecolor{'.$c.GENRE_F.'}{rgb}{'.$r.','.$g.','.$b."}\n";
        return $c;        
    }
    /**************************************************************************!
     * \fn colorName
     **************************************************************************/
    private function colorName($d) {
        $d = str_replace('-', '', $d);
        $d = str_replace("'", '', $d);
        $d = str_replace('è', 'e', $d);
        $d = str_replace('ô', 'o', $d);
        return $d;
    }
}

/******************************************************************************!
 * \class Individu
 ******************************************************************************/
class Individu
{
    var $nom;
    var $prenom;
    var $dateNaissance;
    var $villeNaissance;
    var $depNaissance;
    var $dateMort;
    var $villeMort;
    var $titre;
    var $label;

    /**************************************************************************!
     * \fn construct
     **************************************************************************/
    function __construct($i, $lieu, $departement) {
        $this->nom = strtoupper($i[1]);
        $this->prenom = $i[2];
        $this->dateNaissance = $i[8];
        $this->dateMort = $i[14];
        if (array_key_exists($i[9], $lieu)) {
            $this->villeNaissance = $lieu[$i[9]];
            $this->depNaissance = $departement[$i[9]];
        }
        if (array_key_exists($i[15], $lieu)) {
            $this->villeMort = $lieu[$i[15]];
        }
        $this->titre = $i[6];
        $this->label = str_replace('[', '', $i[0]);
        $this->label = str_replace(']', '', $this->label);
    }
    /**************************************************************************!
     * \fn getColor
     **************************************************************************/
    public function getColor($genre, $departementList) {
        if (! empty($this->depNaissance)) {
            return '='.$departementList->getColor($this->depNaissance).$genre;
        } else {
            return '';
        }
    }
    /**************************************************************************!
     * \fn print
     **************************************************************************/
    public function print($niveau) {
        print '{\begin{tabular}{@{}l@{}}';
        print "$this->nom $this->prenom";
        print "\\\\".
            "$this->dateNaissance~$this->villeNaissance\\\\".
            "$this->dateMort~$this->villeMort";
        if ($niveau < 7) {
            $age = $this->age();
            print "\\\\$age$this->titre";
        }
        if (file_exists("build/$this->label.png")) {
            print '\\\\\\includegraphics{build/'.$this->label.'.png}';
        } else if (file_exists("build/$this->label.jpg")) {
            print '\\\\\\includegraphics{build/'.$this->label.'.jpg}';
        }
        print '\end{tabular}'."}\n";
    }
    /**************************************************************************!
     * \fn age
     **************************************************************************/
    public function age() {
        if (empty($this->dateMort) ||
            empty($this->dateNaissance)) {
            return '';
        }
        $a1 = substr($this->dateNaissance, 0, 4);
        $a2 = substr($this->dateMort, 0, 4);
        if (! is_numeric($a1) ||
            ! is_numeric($a2)) {
            return '';
        }
        $f1 = substr($this->dateNaissance, 0, 10);
        $f2 = substr($this->dateMort, 0, 10);
        if (strlen($f1) <= 4 || substr($f1, 4, 1) != '-' ||
            strlen($f2) <= 4 || substr($f1, 4, 1) != '-') {
            $a = intval($a2) - intval($a1);
            return "$a ans ";
        } else {
            $n = new DateTime($f1);
            $m = new DateTime($f2);
            $a = $n->diff($m);
            return $a->format('%y').' ans ';
        }
    }
}

/******************************************************************************!
 * \class Arbre
 ******************************************************************************/
class Arbre
{
    var $lieu;
    var $departement;
    var $departementList;
    var $individus;
    var $mariage;
    var $famille;
    var $niveau;
    var $anneeMariage;
    var $villeMariage;
    var $pass;
    var $pass2;
    var $parent;
    var $sens;
    var $offsetNode;
    var $offsetDate;
    var $lmax;
    var $below;
    var $left;
    var $right;

    /**************************************************************************!
     * \fn construct
     **************************************************************************/
    function __construct($parent, $lmax, $below, $left, $right) {
        $this->niveau = 0;
        $this->anneeMariage = 0;
        $this->villeMariage = '';
        $this->pass = 0;
        $this->pass2 = 0;
        $this->parent = $parent;
        if ($this->parent == 1) {
            $this->sens = -1;
        } else {
            $this->sens = 1;
        }
        $this->offsetNode = -26.6 * $this->sens;
        $this->offsetDate = -26.6 * $this->sens;
        $this->lmax = $lmax;
        $this->below = $below;
        $this->left = $left;
        $this->right = $right;
    }
    /**************************************************************************!
     * \fn readCSV
     **************************************************************************/
    public function readCSV($filename) {
        $this->departementList = new DepartementList;
        $table = 0;
        if (($f = fopen($filename, "r")) !== false) {
            while (($d = fgetcsv($f, 1000, ",")) !== false) {
                if (empty($d[0])) {
                    continue;
                }
                switch (trim($d[0])) {
                case 'Lieu':
                    $table = LIEU;
                    break;
                case 'Individu':
                    $table = INDIVIDU;
                    break;
                case 'Mariage':
                    $table = MARIAGE;
                    break;
                case 'Famille':
                    $table = FAMILLE;
                    break;
                default:
                    switch ($table) {
                    case LIEU:
                        if ($d[3] == 'Département') {
                            $this->departementList->add($d[2]);
                            $tmpDepartement[$d[0]] = $d[2];
                        } else {
                            $this->lieu[$d[0]] = $d[2];
                            $this->departement[$d[0]] = $tmpDepartement[$d[7]];
                        }
                        break;
                    case INDIVIDU:
                        $this->individus[$d[0]] =
                            new Individu($d, $this->lieu, $this->departement);
                        break;
                    case MARIAGE:
                        $this->mariage[$d[0]] = $d;
                        break;
                    case FAMILLE:
                        $this->famille[$d[1]] = $d[0];
                        break;
                    }
                }
            }
            fclose($f);
        }
    }
    /**************************************************************************!
     * \fn getFirstNodeParent
     **************************************************************************/
    public function getFirstNodeParent($parent) {
        return $this->mariage[array_key_first($this->mariage)][$parent];
    }
    /**************************************************************************!
     * \fn printNode
     **************************************************************************/
    public function printNode($n, $genre) {
        if (empty($n)) {
            return;
        }
        $i = $this->individus[$n];
        for ($j = 0; $j < $this->niveau; ++$j) {
            print ' ';
        }
        if ($this->niveau == 0) {
            print "\\";
        } else {
            print "child{ ";
        }
        $couleur = $i->getColor($genre, $this->departementList);
        print "node [individu$couleur] ";
        print "($i->label) ";
        if ($this->niveau == 4) {
            $offsetX = 3.5 * $this->sens;
            print "at ($offsetX,$this->offsetNode) ";
            if ($this->pass == 1) {
                $this->offsetNode += 7.2 * $this->sens;
                if ($this->pass2 == 1) {
                    $this->offsetNode += 0.9 * $this->sens;
                }
                $this->pass2 = 1 - $this->pass2;
            }
            $this->pass = 1 - $this->pass;
        }
        $i->print($this->niveau);
        if ($this->niveau == 0 && $this->anneeMariage == 0) {
            $this->anneeMariage = $this->mariage[$this->famille[$n]][3];
            $index = $this->mariage[$this->famille[$n]][4];
            if (array_key_exists($index, $this->lieu)) {
                $this->villeMariage = $this->lieu[$index];
            } else {
                $this->villeMariage = '';
            }
        }
        ++$this->niveau;
        if ($this->niveau < $this->lmax) {
            $this->printParents($n);
        }
        --$this->niveau;
        for ($j = 0; $j < $this->niveau; ++$j) {
            print ' ';
        }
        if ($this->niveau > 0 && $this->niveau < $this->lmax - 1) {
            if (! empty($this->famille[$n])) {
                if ($this->niveau > 5) {
                    $s = $this->mariage[$this->famille[$n]][3];
                    if (substr($s, 0, 6) == 'avant ') {
                        $s = 'av. '.substr($s, 6, 4);
                    } else {
                        $s = substr($s, 0, 4);
                    }
                } else {
                    $s = $this->mariage[$this->famille[$n]][3].' ';
                    $index = $this->mariage[$this->famille[$n]][4];
                    if (array_key_exists($index, $this->lieu)) {
                        $s .= $this->lieu[$index];
                    }
                }
                print 'edge from parent node[';
                // left
                if ($this->sens < 0) {
                    print 'left';
                } else {
                    print 'right';
                }
                if ($this->niveau == 4) {
                    $this->left += 50;
                } else if ($this->niveau == 2) {
                    $this->left += 5;
                } else if ($this->niveau == 1) {
                    $this->left += 5;
                }
                print '='.$this->left.'mm';
                // above
                if ($this->niveau == 4) {
                    $this->left -= 50;
                    print ',above='.$this->offsetDate.'cm';
                    if ($this->pass == 0) {
                        $this->offsetDate += 7.2 * $this->sens;
                        if ($this->pass2 == 0) {
                            $this->offsetDate += 0.9 * $this->sens;
                        }
                    }
                } else if ($this->niveau == 2) {
                    $this->left -= 5;
                } else if ($this->niveau == 1) {
                    $this->left -= 5;
                }
                print ']{'."$s}";
            }
        }
        if ($this->niveau == 1 && $this->anneeMariage != 0) {
            print 'edge from parent node[';
            print 'above='.$this->below.'mm,';
            print 'left='.(-30 * $this->sens).'mm';
            print ']{'."$this->anneeMariage $this->villeMariage}";
            $this->anneeMariage = 0;
        }
        if ($this->niveau == 0) {
            print ";\n";
        } else {
            print "}\n";
        }
    }
    /**************************************************************************!
     * \fn printParents
     **************************************************************************/
    private function printParents($n) {
        if (array_key_exists($n, $this->famille)) {
            if ($this->parent == 1) {
                $this->printNode($this->mariage[$this->famille[$n]][1],
                                 GENRE_M);
                $this->printNode($this->mariage[$this->famille[$n]][2],
                                 GENRE_F);
            } else {
                $this->printNode($this->mariage[$this->famille[$n]][2],
                                 GENRE_F);
                $this->printNode($this->mariage[$this->famille[$n]][1],
                                 GENRE_M);
            }
        }
    }
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
if ($argv[1] == 'tests') {
    function testAge($n,$m,$a)
    {
        $i = new Individu(array('','','','','','','','',
                                $n,'','','','','', $m, ''));
        $age = $i->age();
        if ($age != $a) {
            print "error: age $age($n, $m, $a)\n";
            exit(1);
        }
    }
    testAge('2000-02-02', '2001-02-02', 1);
    testAge('2000-02-02', '2001-02-01', 0);
    testAge('2000-02-02', '2001-01-02', 0);
    testAge('2000-02-02', '2001', 1);
    testAge('2000', '2001-12-31', 1);
    print "OK\n";
} else {
    $a = new Arbre($parent, $lmax, $below, $left, $right);
    $a->readCSV($filename);
    fwrite(STDERR, 'Lieux: '.count($a->lieu)."\n");
    fwrite(STDERR, 'Individus: '.count($a->individus)."\n");
    fwrite(STDERR, 'Mariages: '.count($a->mariage)."\n");
    fwrite(STDERR, 'Familles: '.count($a->famille)."\n");
    if ($parent == 1) {
        $genre = GENRE_M;
    } else {
        $genre = GENRE_F;
    }
    $a->printNode($a->getFirstNodeParent($parent), $genre);
}
?>
