use <gears/gears.scad>;
use <servos.scad>;
use <utils.scad>;

$fn = 140;
$fa = 100;
$fs = .10;

modul = 1;
tooth_number = 13;
gearT = 6;
bore = 5;

D = modul*tooth_number;
echo(D);
length = 1;
helix_angle=45;



BEARINGD = 12;
BEARINGT = 5;


module axle_w_gear(modul, ntooth, cut=false){
	L = 25;
	D = 12;
	
	module axle(){
	difference(){
		cylinder(h=L, r=D/2);
		for (j=[0,1]) translate([0,0,j*L]) cylinder(h=20, r=BOLT3TIGHT/2, center=true);
		}
	}
	module gear(){
	rotate([0,0,-45])
	intersection(){
		hull(){
		cube([100, 100, gearT]);
		cylinder(h=gearT, r=D/2);
		}
		herringbone_gear(modul, ntooth, gearT, 
			 D/2, 
			 pressure_angle=20, 
			 helix_angle=helix_angle, 
			 optimized=false);
	}
	}
	

	sp = .5;
	module bearings(sp1=0){
		BEARINGT = BEARINGT + sp1;
		BEARINGD = BEARINGD + sp1;	
		for (z=[-BEARINGT-2*sp, L+2*sp]) translate([0,0,z]) cylinder(h=BEARINGT, r=BEARINGD/2);
	}

	
	module gear_cutter(){	
		translate([0,0,-sp]){ 
		intersection(){
		translate([-D/2, -50, 0]) cube([100, 100, gearT+2*sp]);
		cylinder(h=gearT+sp*2, r=(ntooth*modul)/2 + modul*2);
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
		bearings(sp1=.1);
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
	}
	else{cutters();}
}

module servo_mount_w_axle(top, bolts=false){
	ntooth2 = 26;
	ntooth1 = 14;
	pitchD1 = ntooth1*modul;
	pitchD2 = ntooth2*modul;
	gearsp = .3;

	module servo(cut){
		sp = .5;
		translate([(pitchD1+pitchD2)/2+gearsp, 0, gearT + sp])
		rotate([0,180,180]) 
		kst_servo(cut=cut, hornR=pitchD1/2 + modul + 2*gearsp, hornT=gearT + sp*2);
		if (cut){ }

	}	

	

	wallT = 1;
	baseW = 57;
	baseH = 39;
	baseT = BEARINGD/2 + wallT;

	module base(){
		Z = BEARINGT + 2;
		X = BEARINGD/2 + wallT + 7;	
		k = top ? 1 : -1;

		difference(){
			translate([baseW/2-X, k*baseT/2, (baseH/2-Z)]) cube([baseW, baseT, baseH], center=true);
			axle_w_gear(modul, ntooth2, cut=true);
			servo(cut=true);
			bolts();
		}
	}
	

	module bolts(boltD=BOLT3TIGHT){
		sink = .5;
		boltL = baseT*3;
		points = [[-9, 0, -4], [-9, 0, 29],
			  [9, 0, 29], [9, 0, -4],
			  [40, 0, 29], [32, 0, 2]];
		
		for (p=points){
			translate(p) rotate([-90,0,0]) translate([0,0,-baseT]) bolt(boltL, boltD, sink);
		}
	}
	
	// Return:	
	if (!bolts){base();}
	else if (bolts) {bolts();}

}

BOLT3TIGHT=2.8;
BEARINGAXLED= 5;


servo_gear(modul, 14, gearT);
//servo_mount_w_axle(false);
//axle_w_gear(modul, 26);
//kst_servo(cut=true, hornR=2);

