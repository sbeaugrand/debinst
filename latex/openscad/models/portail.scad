/******************************************************************************!
 * \file portail.scad
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
$fn=32;
hS=17;
module solivette(l) {
  color("chocolate") translate([l/2,0,hS/2]) cube([l,3.2,hS],center=true);
}

/******************************************************************************!
 * Piliers
 ******************************************************************************/
lE=32.5;
hE=16.7;
hJoint=1.2;
module element() {
  pJoint=0.8;
  difference() {
    cube([lE,lE,hE-hJoint]);
    translate([     -0.1,(lE-hJoint)/2,0]) cube([pJoint+0.1,hJoint,hE-hJoint]);
    translate([lE-pJoint,(lE-hJoint)/2,0]) cube([pJoint+0.1,hJoint,hE-hJoint]);
  }
  translate([pJoint,pJoint,hE-hJoint]) cube([lE-pJoint*2,lE-pJoint*2,hJoint]);
}

lC=40;
hC=4.5;
module chapeau() {
  cube([lC,lC,hC]);
}

module pilier() {
  color("darkgray") {
    n=9;
    for (i=[0:2:n-1]) {
      translate([lE,0,hE*i]) rotate([0,0,90]) element();
    }
    for (i=[1:2:n-1]) {
      translate([0,0,hE*i]) element();
    }
    translate([-(lC-lE)/2,-(lC-lE)/2,hE*n]) chapeau();
  }
}
l1=546-lE+21;  // 21 = longueur de l'ancien pilier
l2=355-lE+21;
l3=420-lE+21;
l4=446-lE+21;
l5=168-lE+21;
l6=346-lE+21;
pilier();
translate([lE+l3                  ,0,0]) pilier();
translate([lE+l3+lE+l4            ,0,0]) pilier();
translate([lE+l3+lE+l4+lE+l5      ,0,0]) pilier();
translate([lE+l3+lE+l4+lE+l5+lE+l6,0,0]) pilier();
translate([-l2-lE      ,0,0]) pilier();
translate([-l2-lE-l1-lE,0,0]) pilier();

/******************************************************************************!
 * Clotures
 ******************************************************************************/
pMur=20;
hMur=29;
pPivot=5.4;
hPivot=11.5;
ePivot=2;
zPivot=hE-hJoint-hPivot;
hAxe=1;
hNylon=0.5;
eS=(100-hS*4)/3;
pG=3;
hG=hS*3+eS*2;
zG=zPivot+ePivot+hAxe+hNylon+hS+eS;
echo("ecart solivettes",eS);  // 10.7

hPoteau=hG+(zG-hMur)*2;
echo("hauteur poteau",hPoteau);  // 85.3
module poteau() {
  color("chocolate") cube([hS,hS,hPoteau]);
}

module cloture(l) {
  translate([0,(lE-pMur)/2,0]) color ("beige") cube([l,pMur,hMur]);
  translate([-hS/2    ,(lE-hS)/2,hMur]) poteau();
  translate([-hS/2+l/2,(lE-hS)/2,hMur]) poteau();
  translate([-hS/2+l  ,(lE-hS)/2,hMur]) poteau();
  for (i=[0:2]) {
    translate([0,lE/2,zG+hG-hS-(hS+eS)*i]) solivette(l);
  }
}
translate([-l1-lE-l2,0,0]) cloture(l1);
translate([       lE,0,0]) cloture(l3);
translate([ lE+l3+lE,0,0]) cloture(l4);
translate([lE+l3+lE+l4+lE+l5+lE,0,0]) cloture(l6);

/******************************************************************************!
 * Portails
 ******************************************************************************/
module pivot() {
  color("black") union() {
    cube([8-pPivot/2,pPivot,ePivot]);
    translate([8-pPivot/2,pPivot/2,0]) cylinder(ePivot,d=pPivot);
    cube([0.4,pPivot,hPivot]);
  }
  color("lightgrey")
    translate([pG+pG/2,pPivot/2,ePivot]) cylinder(hAxe,d=2.5,$fn=6);
}

module portail(l,s) {
  a=s*180*(abs($t-0.5)-0.5);
  for (i=[0:3]) {
    rotate([0,0,a])
      translate([pG/2,0,zG+hG-hS-(hS+eS)*i]) solivette(l-pG*2);
  }
  color("black") rotate([0,0,a]) translate([0,0,zG]) {
    h=hG+hS+eS+hNylon*2;
    translate([   0,0,100/2-hS-eS]) cube([pG,pG,h],center=true);
    translate([l-pG,0,100/2-hS-eS]) cube([pG,pG,h],center=true);
  }
  translate([-pG-pG/2,-pPivot/2,zPivot]) pivot();
  translate([-pG-pG/2, pPivot/2,hG+zG+ePivot+hAxe+hNylon])
    rotate([180,0,0]) pivot();
}
translate([-l2+pG+pG/2,lE/2,0]) portail(l2/2-pG-0.5,1);
translate([   -pG-pG/2,lE/2,0])
  rotate([0,0,180]) portail(l2/2-pG-0.5,-1);
translate([lE+l3+lE+l4+lE+l5-pG-pG/2,lE/2,0])
  rotate([0,0,180]) portail(l5-pG-1,1);

/******************************************************************************!
 * Boite aux lettres
 ******************************************************************************/
lB=30;
pB=40;
module boiteAuxLettres() {
  m=3;
  e=0.5;
  color("green") cube([lB,pB,lB]);
  color("silver") translate([m,-e,lB-10]) cube([lB-m*2,e,5]);
}
translate([lE+l3+lE+l4-lB,(lE-pB)/2,hMur+hPoteau]) boiteAuxLettres();
