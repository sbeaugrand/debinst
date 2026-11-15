/******************************************************************************!
 * \file runeDagaz.scad
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note sudo apt install openscad-mcad
 *
 *       *dagaz emblematiserait une capacite' a eliminer toute chose ne
 *       s'integrant pas dans une vision du monde reconduisant au "principe" et,
 *       consequemment, au "Centre supreme", le lieu fondateur du developpement
 *       civilisationnel."
 *       (Paul-Georges Sansonetti, La Cathedrale Polaire des Runes, ACE, p. 28)
 ******************************************************************************/
T=2+0.2; // Diametre de l'outil plus une marge
L=20;    // Longueur du support
P=30;    // Profondeur du support
H=3;     // Hauteur du support
M=1;     // Marge au bord
l=14;    // Longueur de la rune
p=1.5;   // Profondeur des segments
e=1.5;   // Epaisseur des segments
m=0.01;  // Marge pour les differences
conv=false;  // Garder les angles convexes
s=sqrt(2)/2;
$fn=128;

difference() {
  translate([0,0,-(H+M)/2]) cube([L+M*2,P+M*2,H+M],center=true);
  translate([0,0,-H]) hull() {
    r=4;
    x=L/2-r;
    y=P/2-r;
    translate([-x,-y,0]) cylinder(H+m,r=r);
    translate([-x, y,0]) cylinder(H+m,r=r);
    translate([ x, y,0]) cylinder(H+m,r=r);
    translate([ x,-y,0]) cylinder(H+m,r=r);
  }
}

translate([0,0,-H+e/2+m]) difference() {
  h=l+p/s;
  echo("h = ", h);
  union() {
    translate([-l/2+p/2,0,0]) cube([p+m*2,h-p/s*2,e],center=true);
    translate([ l/2-p/2,0,0]) cube([p+m*2,h-p/s*2,e],center=true);
    rotate([0,0, 45]) cube([p,l/s+p,e],center=true);
    rotate([0,0,-45]) cube([p,l/s+p,e],center=true);
  }
  translate([-l/2-p/2,0,0]) cube([p,h,e+m],center=true);
  translate([ l/2+p/2,0,0]) cube([p,h,e+m],center=true);
  if (! conv) {
    translate([ l/2-T/2-p,0,0]) cube([T,h,e+m],center=true);
    translate([-l/2+T/2+p,0,0]) cube([T,h,e+m],center=true);
    translate([-p*s-T/2,0,-H/2]) cylinder(H+m,d=T);
    translate([ p*s+T/2,0,-H/2]) cylinder(H+m,d=T);
    translate([0,-p*s-T/2,-H/2]) cylinder(H+m,d=T);
    translate([0, p*s+T/2,-H/2]) cylinder(H+m,d=T);
  }
}

module oblong(s) {
  hull() {
    r=1;
    l=2;
    translate([-l/2,(P/2-r-T)*s,-H]) cylinder(e,r=r);
    translate([ l/2,(P/2-r-T)*s,-H]) cylinder(e,r=r);
  }
}
oblong( 1);
//oblong(-1);
