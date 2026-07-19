/******************************************************************************!
 * \file runeDagaz.scad
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note sudo apt install openscad-mcad
 ******************************************************************************/
T=2;    // Diametre de l'outil
L=30;   // Longueur du support
P=20;   // Profondeur du support
H=3;    // Hauteur du support
M=1;    // Marge au bord
l=15;   // Longueur de la rune
p=2;    // Profondeur des segments
h=1;    // Hauteur de la rune
m=0.1;  // Marge pour les differences
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

translate([0,0,-H+h/2+m]) difference() {
  s=sqrt(2)/2;
  union() {
    translate([0,-l*s/2-p/2-m,0]) cube([l-2,p+m,h+m],center=true);
    translate([0, l*s/2+p/2+m,0]) cube([l-2,p+m,h+m],center=true);
    rotate([0,0, 45]) cube([(l+1)/s,p,h+m],center=true);
    rotate([0,0,-45]) cube([(l+1)/s,p,h+m],center=true);
  }
  translate([0,-l*s/2-p/2-p,0]) cube([l+4,p+m,h+m*2],center=true);
  translate([0, l*s/2+p/2+p,0]) cube([l+4,p+m,h+m*2],center=true);
}

hull() {
  r=1;
  l=2;
  translate([-L/2+r+T,-l/2,-H]) cylinder(h,r=r);
  translate([-L/2+r+T, l/2,-H]) cylinder(h,r=r);
}

hull() {
  r=1;
  l=2;
  translate([L/2-r-T,-l/2,-H]) cylinder(h,r=r);
  translate([L/2-r-T, l/2,-H]) cylinder(h,r=r);
}
