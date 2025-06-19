/******************************************************************************!
 * \file assemblage.scad
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
module trouDAssemblage(x,y,d,e) {
    translate([x,y,-1]) cylinder(h=e+2,d=d);
    translate([x,y, 1]) cylinder(h=e,d1=d,d2=d+e*sqrt(3));
}
function patteP(L) = 15;
function patteL1(L) = (L==60)?14:(L==80)?18:(L==100)?26:(L==120)?33:(L==140)?46:55;
function patteL2(L) = (L==60)?19:(L==80)?28:(L==100)?27:(L==120)?36:30;
module patte(L) {
    l=patteP(L);
    d=4.5;
    e=2;
    L1=patteL1(L);
    L2=patteL2(L);
    L3=(L-2*L1-L2)/2;
    difference() {
        union() {
            translate([l/2,0,0]) cube([L-l,l,e]);
            translate([  l/2,l/2,0]) cylinder(h=e,d=l);
            translate([L-l/2,l/2,0]) cylinder(h=e,d=l);
        }
        trouDAssemblage(L3     ,l/2,d,e);
        trouDAssemblage(L3+L1  ,l/2,d,e);
        trouDAssemblage(L-L3   ,l/2,d,e);
        trouDAssemblage(L-L3-L1,l/2,d,e);
    }
}
function equerreP(L) = (L==100)?16:(L==120)?18:15;
function equerreL1(L) = (L==30)?10:(L==40)?12:(L==80)?17:(L==100)?26:(L==120)?30:16;
function equerreL2(L) = (L==30)?14:(L==40)?22:(L==80)?55:(L==100)?60:(L==120)?77:(L==50)?25:(L==60)?35:46;
module equerre(L) {
    l=equerreP(L);
    d=4.5;
    e=2;
    L1=equerreL1(L);
    L2=equerreL2(L);
    module patte() {
        difference() {
            union() {
                translate([e+1,0,0]) cube([L-l/2-e-1,l,e]);
                translate([L-l/2,l/2,0]) cylinder(h=e,d=l);
            }
            trouDAssemblage(L1   ,l/2,d,e);
            trouDAssemblage(L1+L2,l/2,d,e);
        }
    }
    union() {
        patte();
        translate([0,l,0]) rotate([0,-90,180]) patte();
        translate([e+1,l,e+1]) rotate([90,0,0]) intersection() {
            difference() {
                cylinder(h=l,r=e+1);
                translate([0,0,-1]) cylinder(h=l+2,r=1);
            }
            translate([-e-2,-e-2,-1]) cube([e+2,e+2,l+2]);
        }
    }
}
y=30;
translate([0,0*y,0]) equerre(30); translate ([40,0*y,0]) patte(160);
translate([0,1*y,0]) equerre(40); translate ([50,1*y,0]) patte(140);
translate([0,2*y,0]) equerre(50); translate ([60,2*y,0]) patte(120);
translate([0,3*y,0]) equerre(60); translate ([70,3*y,0]) patte(100);
translate([0,4*y,0]) equerre(70); translate ([80,4*y,0]) patte(80);
translate([0,5*y,0]) equerre(80); translate ([90,5*y,0]) patte(60);
translate([0,6*y,0]) equerre(100);
translate([0,7*y,0]) equerre(120);
