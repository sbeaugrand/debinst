/******************************************************************************!
 * \file led-ring.scad
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
$fn=32;
D=5.8;
module led() {
    h=8.7;
    r=2.5;
    union() {
        cylinder(h=1,d=D);
        translate([0,0,1]) cylinder(h=h-r-1,r=r);
        translate([0,0,h-r]) sphere(r=r);
    }
}
A=30;
R=19;
iusb=0.48;  // < 0.5A
iled=0.03;
nled=iusb/iled;
echo(n=nled);
module leds() {
    for(i=[0:360/nled:360]) {
        rotate([0,0,i]) translate([R,0,0]) rotate([0,A-90,0]) led();
    }
}
H1=D/2*cos(A);
H2=8.1-H1;
echo(H1*4*tan(A));
module ring() {
    color("orange") difference() {
        translate([0,0,-H1  ]) cylinder(h=H1+H2,d=R*2+H2*2*tan(A)+3);
        translate([0,0,-H1*2]) cylinder(h=(H1+H2)*2,d1=R*2-H1*4*tan(A),d2=R*2+H2*4*tan(A),$fn=128);
        for(i=[0:360/nled:360]) {
            rotate([0,0,i]) translate([R,0,0]) rotate([0,A+90,0]) translate([ 1.27,0,-1]) rotate([0,-A,0]) cylinder(h=10,d=0.8);
            rotate([0,0,i]) translate([R,0,0]) rotate([0,A+90,0]) translate([-1.27,0,-1]) rotate([0,-A,0]) cylinder(h=10,d=0.8);
        }
    }
}
translate([0,0,H1]) leds();
translate([0,0,H1]) ring();
