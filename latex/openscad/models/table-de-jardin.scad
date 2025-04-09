/******************************************************************************!
 * \file table-de-jardin.scad
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
L=3000;  // Longueur plateau
l=700;   // Largeur plateau
T=1500;  // Longueur traverse
H=750;   // Hauteur
pb=160;  // Profondeur bastaing
eb=60;   // Epaisseur bastaing
pd=170;  // Profondeur demi-bastaing
ed=30;   // Epaisseur demi-bastaing
ec=20;   // Ecart plateau/poteau
module planche() { color("yellow") cube([L   ,pd,ed]); }
module  poteau() { color("yellow") cube([H-ed,pb,eb]); }
module trapeze() {
  CubePoints = [
    [0,0,0 ],[l,0,0 ],[l-ec,pb,0 ],[ec,pb,0 ],
    [0,0,eb],[l,0,eb],[l-ec,pb,eb],[ec,pb,eb]];
  CubeFaces = [
    [0,1,2,3],[4,5,1,0],[7,6,5,4],
    [5,6,2,1],[6,7,3,2],[7,4,0,3]];
  color("orange") polyhedron(CubePoints, CubeFaces);
}
module traverse() { cube([T,pb,eb]); }
module tirefond() {  // D8x120mm r<13/sqrt(3)
    color("white") cylinder(h=5,r=7.19,$fn=6  );
    color("black") cylinder(h=1,r=11  ,$fn=180);
}
translate([-L/2,-l/2          ,H-ed]) planche();
translate([-L/2, l/2-pd       ,H-ed]) planche();
translate([-L/2,-(l-pd*4)/6-pd,H-ed]) planche();
translate([-L/2, (l-pd*4)/6   ,H-ed]) planche();
translate([-T/2-eb,  -l/2+ec,   0]) rotate([0,-90,0]) poteau();
translate([ T/2+eb*2,-l/2+ec,   0]) rotate([0,-90,0]) poteau();
translate([-T/2-eb,   l/2-ec-pb,0]) rotate([0,-90,0]) poteau();
translate([ T/2+eb*2, l/2-ec-pb,0]) rotate([0,-90,0]) poteau();
translate([-T/2,   -l/2,H-ed]) rotate([-90,0,90]) trapeze();
translate([ T/2+eb,-l/2,H-ed]) rotate([-90,0,90]) trapeze();
translate([-T/2,eb/2,H-ed-pb-10]) rotate([90,0,0]) traverse();
x=T/2+eb;
z=H-ed;
translate([ x,0,z   -40]) rotate([0, 90,0]) tirefond();
translate([ x,0,z-pb+30]) rotate([0, 90,0]) tirefond();
translate([-x,0,z   -40]) rotate([0,-90,0]) tirefond();
translate([-x,0,z-pb+30]) rotate([0,-90,0]) tirefond();
x2=T/2+eb*2;
y=l/2-ec;
translate([ x2, y   -30,z   -30]) rotate([0, 90,0]) tirefond();
translate([ x2,-y   +30,z   -30]) rotate([0, 90,0]) tirefond();
translate([ x2, y-pb+30,z-pb+30]) rotate([0, 90,0]) tirefond();
translate([ x2,-y+pb-30,z-pb+30]) rotate([0, 90,0]) tirefond();
translate([-x2, y   -30,z   -30]) rotate([0,-90,0]) tirefond();
translate([-x2,-y   +30,z   -30]) rotate([0,-90,0]) tirefond();
translate([-x2, y-pb+30,z-pb+30]) rotate([0,-90,0]) tirefond();
translate([-x2,-y+pb-30,z-pb+30]) rotate([0,-90,0]) tirefond();
