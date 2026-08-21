/******************************************************************************!
 * \file axeZgraveur.scad
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note sudo apt install openscad-mcad
 *
 *       Transmission par un brin de paracorde avec :
 *       - un noeud de chaise cote' graveur;
 *       - un noeud de cabestan cote' arbre moteur.
 ******************************************************************************/
include </usr/share/openscad/libraries/MCAD/stepper.scad>;
include </usr/share/openscad/libraries/MCAD/nuts_and_bolts.scad>;
use <assemblage.scad>;
grL=173;
grP=49;
grH=37;
grB=131;
grZ=-7;
$fn=32;

cP=37.5;
cH=5.5;
module chantPlat(l) {
  color("orange") cube([l,cP,cH]);
}

rD=14;
module rondelle(d1,d2) {
  color("gray") difference() {
    cylinder(1,d=d2);
    translate([0,0,-1]) cylinder(3,d=d1);
  }
}

module boulonPoelier(l,e=0,r=0) {
  d=4;
  dk=10;
  k=2.2;
  color("silver") union() {
    cylinder(l,d=d);
    translate([0,0,-k]) intersection() {
      cylinder(k,d=dk);
      translate([0,0,dk]) sphere(dk);
    }
    if (e > 0) {
      translate([0,0,e]) nutHole(d);
    }
    if (r > 0) {
      translate([0,0,r]) rondelle(d,rD);
    }
  }
}

/******************************************************************************!
 * Elements fixes
 ******************************************************************************/
mZ=240+motorWidth()/2;
module moteur() {
  module prolongementDArbre() {
    translate([-cP/2,11.8,mZ]) rotate([-90,0,0]) cylinder(20,d=6.35);
  }
  color("gray") prolongementDArbre();
  module tuyau() {  // Tuyau en cahoutchouc d'une pompe
    translate([-cP/2,0.1,mZ]) rotate([-90,0,0]) cylinder(30,d=11);
  }
  color("black") tuyau();
  motor(pos=[-cP/2,-cH-0.1,mZ],orientation=[90,0,0]);
  color("gray") translate([-cP/2-60/2,0.1,mZ]) {
    translate([0,0,-motorWidth()/2+12]) rotate([-90,0,0]) patte(60);
    translate([0,0, motorWidth()/2+3 ]) rotate([-90,0,0]) patte(60);
  }
  e=patteL1(60)+patteL2(60)/2;
  translate([-cP/2-e,2+0.1,mZ-e]) rotate([90,0,0]) boulonPoelier(20,cH+2+5);
  translate([-cP/2-e,2+0.1,mZ+e]) rotate([90,0,0]) boulonPoelier(20,cH+2+5);
  translate([-cP/2+e,2+0.1,mZ+e]) rotate([90,0,0]) boulonPoelier(20,cH+2+5);
  translate([-cP/2+e,2+0.1,mZ-e]) rotate([90,0,0]) boulonPoelier(20,cH+2+5);
}
moteur();

gL=ceil(mZ+motorWidth()/2+3);
echo("glissiere",gL);  // 300
module glissiere() {
  color("orange") difference() {
    rotate([0,-90,90]) chantPlat(gL);
    translate([-cP/2,1,mZ]) rotate([90,0,0]) cylinder(cH+2,d=12);
  }
  color("gray") {
    translate([               0,0,0]) rotate([0,0,90]) equerre(30);
    translate([-cP+equerreP(40),0,0]) rotate([0,0,90]) equerre(40);
  }
  translate([-equerreP(30)/2,2,equerreL1(30)+equerreL2(30)])
    rotate([90,0,0]) boulonPoelier(12,cH+2);
  translate([-equerreP(30)/2,2,equerreL1(30)])
    rotate([90,0,0]) boulonPoelier(12,cH+2);
  translate([equerreP(40)/2-cP,2,equerreL1(40)+equerreL2(40)])
    rotate([90,0,0]) boulonPoelier(12,cH+2);
  translate([equerreP(40)/2-cP,2,equerreL1(40)])
    rotate([90,0,0]) boulonPoelier(12,cH+2);
}
glissiere();

module supportLaserBas() {
  e=52;
  z=60;
  echo("support laser",ceil(e*2-cP),"=> 70");  // 67 => 70
  l=70;
  translate([-l/2-cP/2,-cH,z-cP/2]) rotate([90,0,0]) {
    color("khaki") chantPlat(l);
    translate([0,0,cH+0.1]) difference() {
      chantPlat(18);
      color("orange") translate([18/2,cP/2,-1]) cylinder(cH+2,d=3);
    }
    translate([l-18,0,cH+0.1]) difference() {
      chantPlat(18);
      color("orange") translate([18/2,cP/2,-1]) cylinder(cH+2,d=3);
    }
  }
  translate([-cP/2-l/2+18+5,-cH*2,z]) rotate([-90,0,0]) boulonPoelier(20,cH*2);
  translate([-cP/2+l/2-18-5,-cH*2,z]) rotate([-90,0,0]) boulonPoelier(20,cH*2);
}
supportLaserBas();

module supportLaserHaut() {
  x=-60;
  z=200;
  z1=z+equerreP(60)/2;
  z2=z+equerreP(60);
  ll30=equerreL1(30)+equerreL2(30);
  ll60=equerreL1(60)+equerreL2(60);
  color("gray") {
    translate([x,-cH-0.1,z])
      rotate([90,0,0]) equerre(60);
    translate([x+2,-ll60-equerreL1(30)-cH-0.1,z])
      rotate([90,0,90]) equerre(30);
    translate([x,equerreL1(30)-equerreL1(60)-cH-0.1,z2])
      rotate([90,180,0]) equerre(30);
    translate([x-ll30-(140-patteL2(140))/2,2+0.1,z])
      rotate([90,0,0]) patte(140);
  }
  translate([x-ll30,equerreL1(30)-equerreL1(60)-cH-0.1-2,z1])
    rotate([-90,0, 0]) boulonPoelier(20,16);
  translate([x+ll60,-cH-2-0.1,z1])
    rotate([-90,0, 0]) boulonPoelier(20,cH+4+0.1*2);
  translate([x+4,-ll60-cH-0.1,z1])
    rotate([0,-90,0]) boulonPoelier(12,4);
  translate([x+2,-equerreL1(60)-cH-0.1,z1])
    rotate([0,-90,0]) boulonPoelier(12,5,4);
  translate([x+2+ll30,-7-ll60-equerreL1(30)-cH-0.1,z1])
    rotate([-90,0,0]) boulonPoelier(20,10,9);
}
rotate([0,5,0]) supportLaserHaut();

pX=30-cH*2;
module batonDeGlace() {
  p=11;
  h=2;
  translate([-cP/2,cH*2+pX,0]) rotate([0,0,-25]) difference() {
    translate([0,0,-h/2]) cube([40,p,h],center=true);
    translate([0,0,-h-1]) cylinder(h=h+2,d=3.5);
  }
  translate([-equerreP(30)/2,equerreL1(30)+equerreL2(30),-2])
    boulonPoelier(12,h+2+1,h+2);
  translate([equerreP(40)/2-cP,equerreL1(40)+equerreL2(40),-2])
    boulonPoelier(12,h+2+1,h+2);
}
batonDeGlace();

/******************************************************************************!
 * Elements mobiles
 ******************************************************************************/
bD=24;
module boutonRotatif() {
  translate([-grH/2-1,pX,grB]) rotate([0,90,0]) cylinder(grH+2,d=bD);
}

eq=70;
eZ=grB+grZ+(bD/2-4)+equerreP(eq)/2;
echo("support graveur",ceil((grL+grZ-eZ+rD/2)*2),"=> 70");  // 67 => 70
sL=70;
module supportGraveur() {
  color("khaki")
    translate([0,cH*2,eZ-sL/2]) rotate([90,-90,0]) chantPlat(sL);
}
supportGraveur();

echo("palier",ceil(cP+70*2),"=> 180");  // 178 => 180
pL=180;
module palier() {
  color("khaki") {
      translate([-cP,0,0]) rotate([0,-90,90]) chantPlat(cP);
      translate([ cP,0,0]) rotate([0,-90,90]) chantPlat(cP);
  }
  translate([-cP/2-pL/2, cH,0]) rotate([90,0,0]) chantPlat(pL);
  translate([-cP*2     ,-cH,0]) rotate([90,0,0]) chantPlat(cP*3);
  translate([equerreL1(eq)+equerreL2(eq),cH+2,cP/2])
    rotate([90,0,0]) boulonPoelier(12,cH+2);
  translate([-equerreL1(eq)-equerreL2(eq)-cP,cH+2,cP/2])
    rotate([90,0,0]) boulonPoelier(12,cH+2);
}
translate([0,0,eZ-cP/2]) palier();

module etau() {
  z=grB+bD/2-4+equerreP(eq)+grZ;
  color("gray") {
      translate([  0,cH+0.1,z]) rotate([-90,0, 0]) equerre(eq);
      translate([-cP,cH+0.1,z]) rotate([-90,0,90]) equerre(eq);
  }
  module boulon() {
    d=4;
    l=50;
    translate([l/2-cP/2-2.5,equerreL1(eq)+equerreL2(eq)+cH+0.1,0])
      color("silver") rotate([0,-90,0]) {
          translate([0,0,l-2.5*2]) nutHole(d);
          boltHole(d,length=l);
      }
  }
  translate([0,0,z-equerreP(eq)/2]) boulon();
}
etau();

pH=16+17;
module pointe() {
  color("black") translate ([0,pX,pH-16]) cylinder(16,d1=12,d2=21);
  color("gray" ) {
    translate ([0,pX, 0]) cylinder(3,d1=0.1,d2=3.2);
    translate ([0,pX, 3]) cylinder(7,d=3.2);
    translate ([0,pX,10]) cylinder(4,d=5);
    translate ([0,pX,14]) cylinder(2,d1=5,d2=9,$fn=8);
    translate ([0,pX,16]) cylinder(1,d=9);
  }
}

module trapeze() {
  h=10;
  CubePoints = [
    [0,0,0  ],[grP,0,0  ],[grP-15,h,0  ],[30,h,0  ],
    [0,0,grH],[grP,0,grH],[grP-15,h,grH],[30,h,grH]];
  CubeFaces = [
    [0,1,2,3],[4,5,1,0],[7,6,5,4],
    [5,6,2,1],[6,7,3,2],[7,4,0,3]];
  color("orange") polyhedron(CubePoints, CubeFaces);
}

module graveur() {
  iH=133;
  pointe();
  translate([0,-cH,grL]) rotate([-90,0,0]) boulonPoelier(20,cH);
  translate([0,3,grL]) rotate([-90,0,0]) rondelle(4,rD);
  translate([0,5,grL]) rotate([-90,0,0]) rondelle(4,rD);
  color("silver") translate([0,9,grL]) rotate([90,0,0]) nutHole(4);
  color([0.5,0.5,0.5,0.3]) union() {
    intersection() {
      union() {
        translate([-grH/2,0,pH]) cube([grH,grP,iH]);
        translate([0,6,grL-rD/2])
          rotate([90,0,0]) scale([1,1.2,1]) cylinder(3,d=34);
        boutonRotatif();
      }
      translate ([0,pX,pH]) cylinder(grL,d1=21,d2=65);
    }
    intersection() {
      translate([-cP/2,-3,iH+pH]) rotate([90,0,90]) trapeze();
      translate([0,grP/2,iH+pH-6]) sphere(23);
    }
  }
}
translate([-cP/2,cH*2,grZ]) graveur();
