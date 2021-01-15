use <gears/gears.scad>;
use <utils.scad>;
include <standards.scad>;
include <dims.scad>;
module dymond_servo(key="mockup", boltH=2){

	dims = [23.5, 22, 10.2];
	mountpos = [[-2, dims[2]/2], [dims[0] + 2, dims[2]/2]];
	hornpos = [5, dims[1], dims[2]/2];
	hornH = 5;
	boltD = BOLT3TIGHT;

	module horn(){
		rotate([-90,0,0])
		hull(){
		cylinder(h=hornH, r=10/2);
		translate([0,-5,0]) cylinder(h=hornH-1, r=5/2);	
		}
	}

	module mountarms(H=2, key="bolts"){
		armW = 5;
		if (key=="bolts"){
			for (x=[-armW/2, dims[0] + armW/2]){
				translate([x, dims[1] + H, dims[2]/2]) rotate([90,0,0]) bolt(2*H, boltD, 0);
			}
		}
		else if (key=="arm"){
		translate([-armW, dims[1]-2, 0]) cube([dims[1] + 2*armW, 2, dims[2]]);
		}
	}
	module servo(key="mockup"){
		if (key=="mockup"){
		translate(hornpos) rotate([0,90,0]) horn();
		mountarms(H=boltH, key="arm");
		cube(dims);	
		}
		else if (key=="bolts"){
			mountarms(H=boltH, key="bolts");
		}
	}

	translate(-hornpos)
	servo(key);
	 
}


module kst_servo(cut=false, hornR=7, hornT=7, topBearing=false){
	W = 23;
	H = 26.5;
	T = 12;
	
	sp = cut ? .1 : 0;

	module frame(){
		cube([W+2*sp, H+2*sp, T+2*sp]);
	}
	
	module attach(){
		attW = 4.5 + sp;
		attT = 1.2 + sp;
		W_ = W + 2*attW;
		translate([0,19.8,0])
		rotate([90,0,0])
		translate([W_/2-attW, T/2, 0])
		difference(){
		translate([0,sp, -attT/2]) cube([W_, T + 2*sp, attT], center=true);
		if (!cut){
		for (i=[-1,1]){ for (j=[-1,1]){ 
			translate([i*(W/2+2), j*3.5, -.1])cylinder(h=2*attT, r=2.2/2);
		}
		}
		}
		}
	}
	
	module horn(){
		translate([6, H+sp, T/2]) rotate([-90,0,0]) 
		{
		cylinder(h=hornT, r=hornR);
		cylinder(h=12, r=4, center=true);
		if (topBearing){
			translate([0,0,hornT]) cylinder(h=BEARINGT+4*sp, r=BEARINGD/2+sp/2);}
		}
	}
	
	module servo(){	
		frame();	
		attach();
		horn();
		wire();
	}
	
	module wire(){
		translate([-.5,0,T/2])
		rotate([-90,0,0]) 
		{
		translate([0,0,-1.3]) cylinder(h=8+1.3, r=7/2);
		translate([0,0,8]) sphere(r=7/2);
		translate([0, -3.5, -1.3]) cube([35,7, 1.3]);
		}
	}
	
	color("Silver")	
	rotate([90,0,0])
	translate([-6, -H, -T/2])
	if (cut){ 
		translate([-sp, -sp, -sp]) servo();}
	else {servo();}
		
}


module kst_mg215_servo(key="cut", hornT=7, ntooth=15, hornSp=SERVOHORNSP, topBearing=false){

	dims = mg215dims;
	W = dims[0];
	H = dims[1];
	T = dims[2];
	hornX = dims[3];

	hornR = gearD(ntooth, GEARMODUL)/2; //pitchD(ntooth, modul)/2 (ntooth*GEARMODUL)/2 + GEARMODUL; 
	sp = key=="cut" ? .1 : 0;

	module frame(){
		translate([-sp, -sp, -sp]) 
		cube([W+2*sp, H+2*sp, T+2*sp]);
	}
	
	module attach(){
		attW = 4.5 + sp;
		attT = 1.2 + sp;
		W_ = W + 2*attW;
		translate([0,19.8-sp/2,-sp])
		rotate([90,0,0])
		translate([W_/2-attW, T/2, 0])
		difference(){
		translate([0,sp, -attT/2]) cube([W_, T + 2*sp, attT], center=true);
		if (key=="cut"){
		for (i=[-1,1]){ for (j=[-1,1]){ 
			translate([i*(W/2+2), j*3.5, -.1])cylinder(h=2*attT, r=2.2/2);
		}
		}
		}
		}
	}
	
	module horn(key){
		
		translate([hornX, H, T/2]) rotate([-90,0,0]) 	
		if (key=="mockup"){
			servo_gear(GEARMODUL, ntooth, hornT, key="mockup", gearTSp=hornSp, topBearing=topBearing);}
		else {servo_gear(GEARMODUL, ntooth, hornT, key=key, gearTSp=hornSp, topBearing=topBearing);}
	
	}
	
	module servo(key="cutgear"){	
		color("Silver"){
		frame();	
		attach();
		wire();
		}
		horn(key);
	}

	module wire(){
		translate([-.5,0,T/2])
		rotate([-90,0,0]) 
		{
		translate([0,0,-1.3]) cylinder(h=8+1.3, r=7/2);
		translate([0,0,8]) sphere(r=7/2);
		translate([0, -3.5, -1.3]) cube([35,7, 1.3]);
		}
	}
	
	rotate([90,0,0])
	translate([-6, -H, -T/2])
	if (key=="cut"){servo();}
	else if (key=="servo") {servo();}
	else if (key=="mockup") {servo(key="mockup");}
	else if (key=="servogear"){horn("gear");}
		
}


module servo_gear(modul, ntooth, gearT, gearTSp=SERVOHORNSP, key="gear", helix_angle=HELIXANGLE, topBearing=false, bearingdims=SERVOBEARINGDIMS){
	// Gear for servo:
	sp = TIGHTSP;
	boreD = 5 - sp;
	servoaxleH = 3.8;

	module gear(gearT){
		herringbone_gear(modul, ntooth, gearT, 
			 	 boreD, 
			 	 pressure_angle=20, 
			 	 helix_angle=helix_angle, 
			 	 optimized=false);

		translate([0,0,servoaxleH]) cylinder(h=gearT-servoaxleH, r=boreD/2+sp);
		if (topBearing){
			translate([0,0,gearT]) cylinder(h=bearingdims[2] + gearTSp, r=bearingdims[0]/2-sp);
		}
	}	
	
	module cut(key){
		//gearT = gearT + gearTSp*2;
		R = gearD(ntooth, modul)/2 + gearTSp;	
		//translate([0,0,-gearTSp]){
		if (key=="cut"){cylinder(h=gearT + gearTSp*2, r=R);}
		if (topBearing){
			translate([0,0,gearT + gearTSp*2]) {
			cylinder(h=bearingdims[2]+2*sp, r=bearingdims[1]/2 + sp);
			cylinder(h=bearingdims[2]+2*sp + 1, r=bearingdims[0]/2 + 1);}
			}
		//}
		
	}
	color(GEARCOLOR)
	if (key=="gear"){
		gear(gearT);
	}
	else if (key=="mockup"){
		translate([0,0,gearTSp]) 
		gear(gearT);
		echo(gearT);
		cut();	
	}
	else if (key=="cutgear"){	
		cut("cut");
	}
}


kst_mg215_servo(key="mockup", topBearing=true);
translate([5,0,0])kst_mg215_servo(key="cut", topBearing=true);
//servo_gear(modul, ntooth, gearT, gearTSp=SERVOHORNSP, key="gear", helix_angle=HELIXANGLE, topBearing=false, bearingdims=SERVOBEARINGDIMS);
//translate([5,0,0]) servo_gear(GEARMODUL, SERVOGEARNTOOTH, SERVOHORNT, gearTSp=SERVOHORNSP, key="gear", helix_angle=HELIXANGLE, topBearing=true, bearingdims=SERVOBEARINGDIMS);
//servo_gear(GEARMODUL, SERVOGEARNTOOTH, SERVOHORNT, gearTSp=SERVOHORNSP, key="mockup", helix_angle=HELIXANGLE, topBearing=true, bearingdims=SERVOBEARINGDIMS);
//translate([-5,0,0])servo_gear(GEARMODUL, SERVOGEARNTOOTH, SERVOHORNT, gearTSp=SERVOHORNSP, key="cutgear", helix_angle=HELIXANGLE, topBearing=true, bearingdims=SERVOBEARINGDIMS);
