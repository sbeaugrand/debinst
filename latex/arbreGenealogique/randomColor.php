<?php
/******************************************************************************!
 * \file randomColor.php
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
class RandomColor
{
    var $hue;

    /**************************************************************************!
     * \fn construct
     **************************************************************************/
    function __construct($h) {
        $this->hue = $h;
    }
    /**************************************************************************!
     * \fn rgb
     **************************************************************************/
    public function rgb($s, $v) {
        return $this->hsvToRgb($this->hue, $s, $v);
    }
    /**************************************************************************!
     * \fn nextRgb
     **************************************************************************/
    public function nextRgb($s, $v) {
        $this->hue += 0.618033988749895;
        if ($this->hue > 1.0) {
            $this->hue -= 1.0;
        }
        return $this->hsvToRgb($this->hue, $s, $v);
    }
    /**************************************************************************!
     * \fn hsvToRgb
     * \note HSV values in [0..1[
     **************************************************************************/
    private function hsvToRgb($h, $s, $v)
    {
        $h_i = intval($h * 6);
        $f = $h * 6 - $h_i;
        $p = $v * (1 - $s);
        $q = $v * (1 - $f * $s);
        $t = $v * (1 - (1 - $f) * $s);
        switch ($h_i) {
            case 0: $r = $v; $g = $t; $b = $p; break;
            case 1: $r = $q; $g = $v; $b = $p; break;
            case 2: $r = $p; $g = $v; $b = $t; break;
            case 3: $r = $p; $g = $q; $b = $v; break;
            case 4: $r = $t; $g = $p; $b = $v; break;
            case 5: $r = $v; $g = $p; $b = $q; break;
        }
        return array($r, $g, $b);
    }
}
?>
