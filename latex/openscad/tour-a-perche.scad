/******************************************************************************!
 * \file tour-a-perche.scad
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
hc = 1050;  // Hauteur coude
L = 1200;   // Longueur gros tasseau
P = 94;     // Profondeur gros tasseau
E = 35;     // Epaisseur gros tasseau
l = 1200;   // Longueur tasseau
p = 56;     // Profondeur tasseau
e = 21;     // Epaisseur tasseau
lp = 300;   // Longueur parement
lt = 300;   // Longueur tenon
hp = 200;   // Hauteur pointes
H = hc-hp;     // Hauteur glissiere
ls = L*2-H*2;  // Longeur support
pp = L-ls;     // Position poupee
module glissiere() { cube([L,E,P]); }
color("orange") translate([0,-E,0]) glissiere();
color("green" ) translate([0, E,0]) glissiere();
module pied() { cube([H,E,P]); }
color("gray") translate([0,  0,P]) rotate([0,90,0]) pied();
color("gray") translate([L-P,0,P]) rotate([0,90,0]) pied();
module poupee() { difference() {
  cube([lp+lt,E,P]);
  translate([lt+P,-1,(P-e)/2]) cube([p-5,E+2,e]); } }
color("orangered"  ) translate([pp,   0,P+lp]) rotate([0,90,0]) poupee();
color("yellowgreen") translate([L-P*2,0,P+lp]) rotate([0,90,0]) poupee();
module parement() { cube([lp,E,P]); }
color("darkorange") translate([pp,   -E,P+lp]) rotate([0,90,0]) parement();
color("darkorange") translate([pp,    E,P+lp]) rotate([0,90,0]) parement();
color("darkgreen" ) translate([L-P*2,-E,P+lp]) rotate([0,90,0]) parement();
color("darkgreen" ) translate([L-P*2, E,P+lp]) rotate([0,90,0]) parement();
module perche() { cube([e,p,l]); }
color("khaki"    ) translate([-e,-p/2+E/2,-l/2+P]) perche();
color("darkkhaki") translate([0, -p/2+E/2,P     ]) perche();
module pointe() { color("gray") cylinder(50,10,1); }
translate([pp+P ,E/2,P+hp]) rotate([0, 90,0]) pointe();
translate([L-P*2,E/2,P+hp]) rotate([0,-90,0]) pointe();
module equerre() { cube([e,200,p]); }
color("violet") translate([pp-e,-E,hp-p]) equerre();
color("violet") translate([L-P ,-E,hp-p]) equerre();
module support() { cube([ls,E,P]); }
color("darkgray") translate([pp-P/2,E*2+0.1,hp]) support();
module clavette() { cube([e,200,p]); }
color("darkviolet") translate([pp +(P-e)/2,E/2-100,-p]) clavette();
color("darkviolet") translate([L-P-(P+e)/2,E/2-100,-p]) clavette();
module piquet() { cylinder(L,20,20); }
translate([P/2,  -20,-L]) piquet();
translate([L-P/2,-20,-L]) piquet();
module pedale1() { cube([500,p,e]); }
module pedale2() { cube([400,p,e]); }
module pedale3() { cube([200,35,e]); }
module pedale() { r = asin(200/500);
  rotate([0,0, r]) translate([0,-p/2,0]) pedale1();
  rotate([0,0,-r]) translate([0,-p/2,0]) pedale1();
  translate([500*cos(r)-p,200,e]) rotate([0,0,-90]) pedale2();
  translate([250*cos(r)-p,100,e]) rotate([0,0,-90]) pedale3(); }
translate([500,-200,P-H]) rotate([0,0,90]) pedale();
// Decoupe
color("darkgreen"  ) translate([0,         1000,0]) parement();
color("green"      ) translate([lp,        1000,0]) glissiere();
color("yellowgreen") translate([lp+L,      1000,0]) poupee();
color("darkgreen"  ) translate([lp+L+lp+lt,1000,0]) parement();
color("darkorange" ) translate([0,         1100,0]) parement();
color("orange"     ) translate([lp,        1100,0]) glissiere();
color("orangered"  ) translate([lp+L,      1100,0]) poupee();
color("darkorange" ) translate([lp+L+lp+lt,1100,0]) parement();
color("gray"       ) translate([0,         1200,0]) pied();
color("darkgray"   ) translate([H,         1200,0]) support();
color("gray"       ) translate([H+700,     1200,0]) pied();
color("khaki"      ) translate([0,    800,0]) rotate([0,90,0 ]) perche();
color("darkkhaki"  ) translate([1200, 800,0]) rotate([0,90,0 ]) perche();
color("violet"     ) translate([0,    900,0]) rotate([0,0,-90]) equerre();
                     translate([200,  900,0]) rotate([90,0,0 ]) pedale1();
color("darkviolet" ) translate([700,  900,0]) rotate([0,0,-90]) clavette();
                     translate([900,  900,0]) rotate([90,0,0 ]) pedale1();
color("violet"     ) translate([1400, 900,0]) rotate([0,0,-90]) equerre();
                     translate([1600, 900,0]) rotate([90,0,0 ]) pedale2();
color("darkviolet" ) translate([2000, 900,0]) rotate([0,0,-90]) clavette();
