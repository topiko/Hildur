use <gears/gears.scad>;
use <servos.scad>;
use <utils.scad>;
include <standards.scad>;



module axle_w_gear(GEARMODUL, ntooth, turnAngle, turnAngleMiddle=0, turnArmW=6, key="buildall"){
	L = 27;
	D = 12;
	

	module axle(){
	difference(){
		cylinder(h=L, r=D/2);
		for (j=[0,1]) translate([0,0,j*L]) cylinder(h=20, r=BOLT3TIGHT/2, center=true);
		// Bore for arm:
		rotate([0,0,turnAngleMiddle]) translate([0,0,L/2]) rotate([-90,0,0]) cylinder(h=D*2, r=turnArmW/2, center=true);
		}
	}
	
	module bearing_axles(){
		addH = 3;
		// Spacing between bearing bore wall and axle.
		sp_bearing = .02;
		
		
		bearingAxleL = 2*sp + BEARINGT + 3;
		
		module axle(){
			difference(){
			union(){
			cylinder(h=bearingAxleL, r=BEARINGAXLED/2-sp_bearing);
			cylinder(h=addH-.2, r=BOLT3LOOSE+1.0);
			cylinder(h=addH, r=BEARINGAXLED/2+.5);
			}
			bolt(2*bearingAxleL, BOLT3LOOSE, 0);
			}
		}

		shift = -2*sp - BEARINGT - addH	;
		translate([0,0,shift]) axle();
		translate([0,0,L-shift]) mirror([0,0,1]) axle();
	}

	module gear(key){
	turnAngle = (key!="gear") ? turnAngle*2 : turnAngle;
	R = (GEARMODUL*ntooth + 3*GEARMODUL)/2;
	T = (key!="gear") ? GEART + 2*sp : GEART; 
	shift = (key!="gear") ? sp : 0;

	// Due to the fact hta the axle has diameter:
	addAngle = asin(D/(2*L));
	translate([0,0,-shift])
	rotate([0,0,-turnAngle/2])
	intersection(){
		hull(){
			echo(addAngle);
			rotate([0,0,-addAngle]) 
			rotate_extrude(angle=turnAngle + 2*addAngle) square([R, L]);
			cylinder(h=T, r=D/2);
		}
		if (key=="gear"){
			herringbone_gear(GEARMODUL, ntooth, GEART, 
				 D/2, 
			 	pressure_angle=20, 
			 	helix_angle=HELIXANGLE, 
			 	optimized=false);
		}
		else {
			cylinder(h=T, r=R);
		}
	}

	}
	

	sp = 0.66;
	module bearings(sp1=0){
		BEARINGT = BEARINGT + sp1;
		BEARINGD = BEARINGD + sp1;	
		for (z=[-BEARINGT-2*sp, L+2*sp]) translate([0,0,z]) cylinder(h=BEARINGT, r=BEARINGD/2);
	}

	/*
	module gear_cutter(){	
		translate([0,0,-sp]){ 
		intersection(){
		translate([-D/2, -50, 0]) cube([100, 100, GEART+2*sp]);
		cylinder(h=GEART+sp*2, r=(ntooth*GEARMODUL)/2 + GEARMODUL);
		}
		}	
	}*/

	module axle_cutter(){
		// Due to the fact hta the axle has diameter:
		addAngle = asin(D/(2*50));

		turnArmW = turnArmW + 2*sp;
		module wedge(){	
			L = L + 2*sp;
			rotate([0,0,turnAngleMiddle])
			hull(){
			cylinder(h=turnArmW, r=turnArmW/2);
			rotate([0,0, -addAngle]) rotate_extrude(angle=turnAngle + 2*addAngle) square([50, turnArmW]);
			}
		}
		
		rotAngle = (180 - turnAngle)/2;
		translate([0,0,-sp]) cylinder(h=L+2*sp, r=D/2 + sp);
		translate([0,0,(L-turnArmW)/2]) rotate([0,0,rotAngle]) wedge();
		//mirror([0,1,0]) rotate([0,0,rotAngle]) wedge();
	}
	
	module bearing_cutter(){
		bearings(sp1=.05);
		translate([0,0, L/2]) 
		cylinder(h=2*L, r=BEARINGD/2 - sp, center=true);
	}
	
	
		
	if (key=="cutall"){
		axle_cutter();
		bearing_cutter();
		gear("cutter");
	}
	else if (key=="gear"){
		gear("gear");
	} //gear_cutter();}
	else if (key=="bearingaxles"){
		bearing_axles();
	}
	else if (key=="buildaxle"){
		axle(); 
		gear("gear");
	}
	else if (key=="buildall"){
		axle();
		gear("gear");
		bearing_axles();
	}
}

module servo_mount_w_axle(top, servoNTooth=14, axleNTooth=26, turnAngleMiddle=0, turnArmW=7, key="bottom", roundtip=false, topServoBearing=true, Xs=0, boltsD=BOLT3LOOSE, turnOverride=0, baseH=0){

	turnAngle = turnOverride == 0 ? servoNTooth/axleNTooth*180 : turnOverride;
	pitchD1 = servoNTooth*GEARMODUL;
	pitchD2 = axleNTooth*GEARMODUL;
	gearsp = .2;

	module servo(cut){
		sp = 1.;
		translate([(pitchD1+pitchD2)/2+gearsp, 0, GEART + sp])
		rotate([0,180,180]){ 
		if (!cut){kst_servo(cut=cut, hornR=pitchD1/2 + GEARMODUL, hornT=GEART);}
		if (cut){kst_servo(cut=cut, hornR=pitchD1/2 + GEARMODUL + 2*gearsp, hornT=GEART + sp*2, topBearing=topServoBearing);}
		}
	}	

	

	wallT = 1;
	baseH = baseH == 0 ? 41 : baseH;
	baseT = Xs == 0 ? 6 + wallT: Xs;
	Z = BEARINGT + 3.;
	X = Xs == 0 ? BEARINGD/2 + wallT + 6.5 : Xs;

	baseW = X + pitchD1 + pitchD2/2 + 15;
	module base(){
		k = (key=="top") ? 1 : -1;
		difference(){
			translate([baseW/2-X, k*baseT/2, (baseH/2-Z)]) cube([baseW, baseT, baseH], center=true);
			axle_w_gear(GEARMODUL, axleNTooth, turnAngle, turnAngleMiddle, turnArmW, key="cutall");
			servo(cut=true);
			bolts();
			if (roundtip){
				difference(){
				translate([-X,0,0]) cube([2*X, 2*X, baseH*2], center=true);
				cylinder(h=baseH*2, r=X, center=true);
			}
			}
		}
		//if (roundtip){cylinder(h=baseH*2, r=pitchD2/2+GEARMODUL, center=true);}
	}
	

	module bolts(boltD=boltsD){
		boltD = (key=="bolts") ? BOLT3TIGHT : key=="top" ? BOLT3TIGHT : boltD;
		sink = .5;
		boltL = baseT*1.9;
		s2 =.2;
		s1 = roundtip ? 9 : s2;
		boltshift = roundtip ? -.5 : 0; 
		toprow = -3.9;
		botrow = 31;
		xservoend = baseW - X - BOLT3LOOSE;
		points = [[-9, 0, toprow+boltshift, s1], [-9, 0, botrow, s1],
			  [9, 0, botrow, s2], [9, 0, toprow, s2],
			  [xservoend, 0, botrow, s2], [xservoend, 0, toprow, s2],
			  [xservoend-10, 0, toprow, s2]];
		for (p=points){
			s  =p[3];
			p = [p[0], p[1], p[2]];
			
			translate(p) rotate([-90,0,0]) translate([0,0,-baseT]) bolt(boltL-s - boltD/2, boltD, s, baseL=s);
		}
	}
	
	// Return:		
	translate([0,0,Z-baseH/2]) 
	if (key=="bolts"){
		bolts();
	}
	else if (key=="bottom"){
		base();
	}
	else if (key=="top"){
		base();
	}
	else if (key=="show"){
		base();
		servo(true);
		axle_w_gear(GEARMODUL, axleNTooth, turnAngle, turnAngleMiddle, turnArmW, key="buildall");
	}
	else if (key=="cutmild"){
		axle_w_gear(GEARMODUL, axleNTooth, turnAngle, turnAngleMiddle, turnArmW, key="cutall");
		servo(cut=true);	
		bolts(boltD=BOLT3TIGHT);
	}
	else if (key=="cut"){
		// Add spacing:
		sp = .1;
		baseW_ = 2*sp + baseW;
		baseH_ = 2*sp + baseH;
		baseT_ = 2*sp + baseT*2;
		translate([baseW/2-X-sp, -sp, (baseH/2-Z-sp)]) cube([baseW_, baseT_, baseH_], center=true);
		// These have their respective spacing already:
		axle_w_gear(GEARMODUL, axleNTooth, turnAngle, turnAngleMiddle, turnArmW, key="cutall");
		servo(cut=true);	
		
	}
	else if (key=="onlyaxle"){	
		axle_w_gear(GEARMODUL, axleNTooth, turnAngle, turnAngleMiddle, turnArmW, key="buildall");
		translate([0,0,50]) axle_w_gear(GEARMODUL, axleNTooth, turnAngle, turnAngleMiddle, turnArmW, key="cutall");
	}
	else if (key=="box"){	
		translate([baseW/2-X, 50+baseT, (baseH/2-Z)]) cube([baseW, 100, baseH], center=true);
	}
	else if (key=="axle"){
		 axle_w_gear(GEARMODUL, axleNTooth, turnAngle, turnAngleMiddle, turnArmW, key="buildaxle");
	}
	else if (key=="bearingaxles"){
		 axle_w_gear(GEARMODUL, axleNTooth, turnAngle, turnAngleMiddle, turnArmW, key="bearingaxles");
	}
	else if (key=="servogear"){
		servo_gear(GEARMODUL, servoNTooth, GEART);
	}
}


//$fn = 30;
//$fa = 10;
//$fs = .10;

//servo_mount_w_axle(false, servoNTooth=14, axleNTooth=26, key="bottom");
//servo_mount_w_axle(false, servoNTooth=14, axleNTooth=26, key="top");
//servo_mount_w_axle(false, servoNTooth=14, axleNTooth=26, key="cut");
//servo_mount_w_axle(true, true);
axle_w_gear(GEARMODUL, 26, 90, key="buildall");
//axle_w_gear(GEARMODUL, 26, 90, key="cutall");
//axle_w_gear(GEARMODUL, 26, 90, key="buildaxle");
//axle_w_gear(GEARMODUL, 26, 90, key="bearingaxles");
//servo_gear(GEARMODUL, 14, GEART);


//axle_w_gear(GEARMODUL, 26, 60, cut="gear");
//kst_servo(cut=true, hornR=8, hornT=8);
//kst_servo(cut=true, hornR=8, hornT=8);
//kst_servo(cut=true, hornR=8, hornT=8);
//kst_servo(cut=true, hornR=8, hornT=8);
//kst_servo(cut=true, hornR=8, hornT=8);
//kst_servo(cut=true, hornR=8, hornT=8);

//translate([0,0,1])axle_w_gear(GEARMODUL, 26, 60, cut="gear2");
//kst_servo(cut=true, hornR=8, hornT=8);
