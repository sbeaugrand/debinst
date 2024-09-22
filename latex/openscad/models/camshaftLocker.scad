/******************************************************************************!
 * \file camshaftLocker.scad
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 * \note Bloqueur d'arbre à cames pour Zafira A essence
 *       Not tested
 ******************************************************************************/
dPulley = 116;
rPulley = dPulley/2;
nPulley = 46;
hPulley = 10;
LTeeth = 5;
lTeeth = 3;
hTeeth = 3;
entraxe = dPulley+18.5;
tLocker = 29;
bLocker = 15;
hLocker = tLocker + bLocker;
lLocker = 45;

module camshaftPulley() {
    difference() {
        cylinder(h=hPulley+2, r=rPulley, $fn=180);
        for(i=[1:nPulley])
            rotate([0,0,i*(360/nPulley)])
            translate([rPulley-3,0,-1])
            linear_extrude(height=hPulley+4)
            polygon([[hTeeth*2,lTeeth/2+LTeeth-lTeeth],
                     [0,lTeeth/2],
                     [0,-lTeeth/2],
                     [hTeeth*2,-(lTeeth/2+LTeeth-lTeeth)]]);
    }
}
module camshaftLocker() {
    difference() {
        translate([entraxe/2-lLocker/2,-bLocker,0]) cube([lLocker,hLocker,hPulley]);
        union() {
            translate([0,0,-1]) rotate([0,0,180/nPulley-1]) camshaftPulley();
            translate([entraxe,0,-1]) rotate([0,0,180/nPulley-1]) camshaftPulley();
            translate([entraxe/2-0.5,-bLocker-1,-1]) cube([2.5,hLocker+2,hPulley/2+1]);
            translate([entraxe/2,tLocker+6,-1]) cylinder(h=hPulley+2, r=10, $fn=180);
        }
    }
}
rotate([0,180,0]) translate([-entraxe/2,0,-hPulley]) camshaftLocker();
