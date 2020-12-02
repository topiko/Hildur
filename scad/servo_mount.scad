use <gears/gears.scad>;
use <servos.scad>;
use <utils.scad>;
include <standards.scad>;

$fn = 100;
$fa = 100;
$fs = .10;

//GEARMODUL = 1;
//tooth_number = 13;
//GEART = 6;
//bore = 5;
//D = GEARMODUL*tooth_number;
//length = 1;





module axle_w_gear(GEARMODUL, ntooth, cut=false){
	L = 25;
	D = 12;
	
	module axle(){
	difference(){
		cylinder(h=L, r=D/2);
		for (j=[0,1]) translate([0,0,j*L]) cylinder(h=20, r=BOLT3TIGHT/2, center=true);
		}
	}
	
	module bearing_axles(){
		addH = 3;
		sp_bearing = .05;
		bearingAxleL = 2*sp + BEARINGT + 3;
		module axle(){
		difference(){
		union(){
		cylinder(h=bearingAxleL, r=BEARINGAXLED/2-sp_bearing);
		cylinder(h=addH-.2, r=BOLT3LOOSE+.5);
		cylinder(h=addH, r=BEARINGAXLED/2+.5);
		}
		bolt(2*bearingAxleL, BOLT3LOOSE, 0);
		}
		}
		shift = -2*sp - BEARINGT - addH	;
		translate([0,0,shift]) axle();
		translate([0,0,L-shift]) mirror([0,0,1]) axle();
	}

	module gear(){
	rotate([0,0,-45])
	intersection(){
		hull(){
		cube([100, 100, GEART]);
		cylinder(h=GEART, r=D/2);
		}
		herringbone_gear(GEARMODUL, ntooth, GEART, 
			 D/2, 
			 pressure_angle=20, 
			 helix_angle=HELIXANGLE, 
			 optimized=false);
	}
	}
	

	sp = 1.;
	module bearings(sp1=0){
		BEARINGT = BEARINGT + sp1;
		BEARINGD = BEARINGD + sp1;	
		for (z=[-BEARINGT-2*sp, L+2*sp]) translate([0,0,z]) cylinder(h=BEARINGT, r=BEARINGD/2);
	}

	
	module gear_cutter(){	
		translate([0,0,-sp]){ 
		intersection(){
		translate([-D/2, -50, 0]) cube([100, 100, GEART+2*sp]);
		cylinder(h=GEART+sp*2, r=(ntooth*GEARMODUL)/2 + GEARMODUL*2);
		}
		}	
	}

	module axle_cutter(){
		module wedge(){	
			L = L + 2*sp;
			translate([0,0,-sp])
			hull(){
			cylinder(h=L, r=D/2);
			rotate_extrude(angle=90) square([50, L]);
			}
		}
		
		rotate([0,0,45]) wedge();
		mirror([0,1,0]) rotate([0,0,45]) wedge();
	}
	
	module bearing_cutter(){
		bearings(sp1=.05);
		translate([0,0,-BEARINGT - sp]) 
		translate([0,0,-L]) cylinder(h=3*L, r=BEARINGD/2 - sp);
	}
	
	module cutters(){
		axle_cutter();
		bearing_cutter();
		gear_cutter();
	}

	if (!cut){
		axle();
		//bearings();
		gear();
		bearing_axles();
	}
	else{cutters();}
}

module servo_mount_w_axle(top, bolts=false, boltsD=BOLT3LOOSE){
	ntooth2 = 26;
	ntooth1 = 14;
	pitchD1 = ntooth1*GEARMODUL;
	pitchD2 = ntooth2*GEARMODUL;
	gearsp = .3;

	module servo(cut){
		sp = 1.;
		translate([(pitchD1+pitchD2)/2+gearsp, 0, GEART + sp])
		rotate([0,180,180]){ 
		if (!cut){kst_servo(cut=cut, hornR=pitchD1/2 + GEARMODUL, hornT=GEART);}
		if (cut){kst_servo(cut=cut, hornR=pitchD1/2 + GEARMODUL + 2*gearsp, hornT=GEART + sp*2);}
		}
	}	

	

	wallT = 1;
	baseW = 57.5;
	baseH = 40;
	baseT = BEARINGD/2 + wallT;
	Z = BEARINGT + 3;

	module base(){
		X = BEARINGD/2 + wallT + 6.5;	
		k = top ? 1 : -1;
		difference(){
			translate([baseW/2-X, k*baseT/2, (baseH/2-Z)]) cube([baseW, baseT, baseH], center=true);
			axle_w_gear(GEARMODUL, ntooth2, cut=true);
			servo(cut=true);
			bolts();
		}
	}
	

	module bolts(boltD=boltsD){
		sink = .5;
		boltL = baseT*3;
		points = [[-9, 0, -4], [-9, 0, 29],
			  [9, 0, 29], [9, 0, -4],
			  [41, 0, 29], [32, 0, 2]];
		
		for (p=points){
			translate(p) rotate([-90,0,0]) translate([0,0,-baseT]) bolt(boltL, boltD, sink);
		}
	}
	
	// Return:	
	
	translate([0,0,Z-baseH/2]) 
	if (!bolts){base();}
	else if (bolts) {bolts();}
	
	//axle_w_gear(modul, 26);
	//servo();
}



servo_gear(GEARMODUL, 14, GEART);
//servo_mount_w_axle(false);
//servo_mount_w_axle(true, true);
//axle_w_gear(modul, 26);
//kst_servo(cut=true, hornR=8, hornT=8);

