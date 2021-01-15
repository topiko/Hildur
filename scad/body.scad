use <servo_mount.scad>;
use <servos.scad>;
use <utils.scad>;
use <electronics.scad>;
include <standards.scad>;
include <dims.scad>;
/*
angle = 110;
servoNTooth = 15;
axleNTooth = round(180/angle*servoNTooth);
*/
module battrack(key, wallT=3){
	batD=18.2;
	batL=66;
	bottomT=1;
	T = 7;
	W = bodyW - wallT*2;	
	H = 3*batD  + 8;
	module batt(){
		for (k=[-1,0,1]){
			translate([0, k*batD, batD/2 + bottomT]) rotate([0,90,0]) cylinder(h=batL + 2, r=batD/2, center=true);
		}
	}
	module groowplate(key, W=W,  boltD=BOLT3TIGHT){
		if (key=="plate"){
			difference(){
				translate([0, 0, T/2]) cube([W, H, T], center=true);
				batt();					
			}
		}
		else if (key=="bolts"){
			for (i=[-1,1]){
				translate([bodyW/2*i, 0, 0])
				for (j=[-batD, 0, batD]){
					translate([0, j, T/2]) rotate([0, -i*90, 0]) bolt(6, boltD, .5);
				}
			}
		}
	}
		
	module top(key){
		Z = key == "mocktop" || key == "bolts" ? bottomT*2 + batD : 0;
		translate([0,0,Z])
		mirror([0,0,1])
		if (key=="top"){
			groowplate("plate", W=W-2*TIGHTSP);
		}
		else if (key=="bolts"){
			groowplate("bolts");
		}
	}

	if (key=="bottom"){groowplate("plate");}
	else if (key=="top"){top("top");}
	else if (key=="mocktop"){top("mocktop");}
	else if (key=="cut"){top("bolts"); batt();}
}	



module body(L, W, T, wallT=3, key="none", R = 5){
	
	
	attachH = 7;
	bottomT=1;
	topT = attachH+bottomT; 
	botT = T-topT;
	echo(botT);
	axleX = 8;
	cornerR = 3;

	module servo(key="cut"){
		hornarmL = 20;
		mountT=SERVOBEARINGDIMS[1]+2;
		module servo_(){
			translate([neckX,-botT, L/2 - wallT])
			mirror([1,0,0])
			servo_mount_aligned(key=key, servoNtooth=SERVOGEARNTOOTH, 
					    turnAngle=90, axleL=12, 
					    axlehornDin=AXLEHORNDIN, type=3, 
					    hornarmL=hornarmL, T=mountT);

		}

		module centered_mount(){
			difference(){
				servo_();
				bodyshell(wallT=wallT+.1, key="bottom");
				bodyshell(wallT=wallT+.1, key="top");
			}
		}

		if (key=="top"){			
			// TODO;
			difference(){
				servo_("top");
				bodyshell(wallT=wallT+.1, key="bottom");
			}
		}
		else {servo_();}
	}
		
	module closebolts(key="bolts", boltD=BOLT3TIGHT){
		NH = 3;
		NW = 3;
		edgeD = 8;
		
		dH = (L-2*edgeD)/(NH-1);
		dW = (W-2*edgeD)/(NW-1);
			
		sink = .3;
		mnthH = 2;
		mnthR = 3.5;
		
		module boltrow(N, dx){
			translate([-(N-1)*dx/2, 0, 0])
			
			for (k=[0:1:N-1]){
				translate([k*dx, 0 ,0]) 
				if (key=="bolts"){bolt(mnthH + wallT, boltD, sink);}
				else if (key=="mnts"){
					
					translate([0,0,wallT]) cylinder(h=mnthH, r1=mnthR, r2=mnthR-mnthH);
				}
			}

		}
		module sidebolts(side){
			rotY = side =="left" ? 90 : -90;
			transX = side == "left" ? -W/2 : W/2;
			translate([transX, attachH/2, 0])
			rotate([0, rotY, 0]) 
			boltrow(NH, dH);
		}

		
		sidebolts("left");
		sidebolts("right");
		
		
	}

	module bodyshell(wallT=wallT, key="bottom", bottomT=bottomT, L=L, W=W, T=T, R=R){

		sp = TIGHTSP;

		module bulk(L, W, T, R_){
			rotate([-90,0,0])
			linear_extrude(height=T) offset(R_) square([W-2*R, L-2*R], center=true);
		}
		
		module shell(L, W, T, R, wallT=wallT, bottomT=bottomT){	
			bulkL = 60;
			translate([0,-T,0])
			difference(){
				bulk(L, W, T, R);
				translate([0, bottomT, 0]) bulk(L, W, 2*T, R - wallT);	
			}
		}
		
		module attachring(L, W, T, wallT){
			translate([0,T, 0]) shell(L, W, T, R, wallT=wallT, bottomT=-.1);
		}	

		if (key=="top"){
			difference(){
				mirror([0,1,0]) shell(L, W, topT, R, wallT = wallT);
				attachring(L, W, attachH, wallT/2 + sp);
			}
		}
		else if (key=="bottom"){
			shell(L, W, botT, R, wallT=wallT);
			attachring(L, W, attachH, wallT/2 - sp);
		}
		else if (key=="bulk"){
			translate([0, topT, 0])
			shell(L, W, T, R, wallT=L);
		}
		else if (key=="cutring"){
			attachring(L, W, attachH, wallT/2 + sp);
		}
	

	}
	module shiftedbattrack(key){
		posX = 0;
		posY = -botT;
		posZ = -L/2 + wallT + 57.5 + 18*3/2; //-17;
		if (key!="top"){
			translate([posX, posY, posZ]) rotate([-90,0,0]) 
			battrack(key);
		}
		else if (key=="top"){
			battrack(key);
			// TODO;
			translate([-W/2 + wallT + 2 + 13,0,0])
			rotate([0,0,90])			
			servoctrl(H=1+bottomT, key="mockup", boltH=bottomT);
		}

	}	

	shiftedbattrack("top");
	module shiftedservocontroller(key="mockup"){
		posX = -(W/2 - 16);
		posY = topT;
		posZ = L/2 - 34.8;

		translate([posX, posY, posZ])
		rotate([0,-90,0])
		rotate([90,0,0])
		servoctrl(H=1+bottomT, key=key, boltH=bottomT);
	}
	
	module shiftedmicarray(key="mockup"){	
		posY = topT;
		posZ = L/2 - 65/2 - 66; // L/2 - 35;
		translate([0, posY, posZ]) rotate([90, 0, 0]) micarray(H=1 + bottomT, key=key, boltH=bottomT);	
	}
	

	module motormounts(key="cut"){

		R = WHEELBEARINGDIMS[1];
		T = WHEELBEARINGDIMS[2];
		mountT= R+1;
		axleL = 13;
		wheelbearingXout = T- wallT/2;
		addXR = 6;
		module unit(key){
			translate([W/2 + wheelbearingXout, -botT, -L/2 + wallT + R/2 + addXR])
			rotate([0,90,0])
			servo_mount_aligned(key=key, servoNtooth=22, 
					    turnAngle=110, axleL=axleL, bearingdims=WHEELBEARINGDIMS, 
					    axlehornDin=AXLEHORNDIN, type=5, addXR=addXR, T=mountT);
		}

		module both(key){	
			mirror([1,0,0])unit(key);
			unit(key);
		}
				
		if (key=="bottom"){
			intersection(){
				both(key);
				bodyshell(key="bulk");
			}
		}
		else if (key=="top"){
			subst = 2*(wallT + TIGHTSP);
			intersection(){
				both(key);
				bodyshell(key="bulk", L=L-subst, W=W-subst, T=T-subst, R=cornerR - subst/2);
			}
		}
		else if (key=="cut"){
			both(key);
		}

	
	}
	


	module arm(key){
		
		module servo_(key, boltH=2){	
		posX = -(W/2-wallT);
		posY = -botT + 8;
		posZ = L/2 - 30;
		translate([posX, posY, posZ])
		rotate([90,0,0])
		rotate([0,0,90])
		dymond_servo(key, boltH=boltH);
		}
		if (key=="mockup"){servo_("mockup");}
		else if (key=="cut"){
			servo_(key="bolts", boltH=wallT);
			servo_("mockup");
		} //wallT);
	}	
	
	module cablecutter2(){
		corner = 2;
		cableW = 20;
		posX = -(W/2 - cableW/2 - R - wallT);
		posY = -botT + bottomT + corner + .1;
		posZ = L/2;
		translate([posX, posY, posZ])
		linear_extrude(5*wallT, center=true) offset(corner) square([cableW - 2*corner, .0001], center=true);
	}
	
	
	module shiftedmpu6050(key="cutfromservo"){
		mpudims = [21.4, 17, 2];
		if (key=="cutfromservo"){
			posX = 0;
			posY = -20;
			posZ = -mpudims[2]/2;
			translate([posX, posY, posZ]) 
			cube(mpudims, center=true);
		}
	}
	


	module bottom(){
		module wadds(){
			bodyshell(key="bottom", wallT=wallT);
			intersection(){
				servo("bottom");
				bodyshell(key="bulk", wallT=wallT);
			}	
			intersection(){
				motormounts("bottom");
				bodyshell(key="bulk", wallT=wallT);
			}
			shiftedbattrack("bottom");
		}

		module wcuts(){
			difference(){
			wadds();
			servo("cut");
			//shiftedservocontroller(key="bolts");
			motormounts("cut");
			arm("cut");
			closebolts(key="bolts");
			cablecutter2();
			shiftedbattrack("cut");
			}
			
		}
		wcuts();
	}

	//motormounts("cut");
	module top(){
		module wadds(){
			bodyshell(key="top", wallT=wallT);
			shiftedmicarray(key="poles");
			closebolts(key="mnts");
			shiftedservocontroller(key="poles");
		}

		module wcuts(){
			difference(){
			wadds();
			//servo("cut");
			shiftedmicarray(key="bolts");
			shiftedmicarray(key="micsleds");
			motormounts("cut");
			closebolts(key="bolts");
			bodyshell(key="cutring", wallT=wallT);
			shiftedservocontroller(key="bolts");
			}
			
		}
		wcuts();
	}
	

	if (key=="mockup"){
		translate([0,0, L/2]){
		bodyshell(key="top");
		bodyshell(key="bottom");
		}
	}
	else if (key=="bottom"){
		bottom();
	}
	else if (key=="top"){
		top();
	}
	else if (key=="servobottom"){
		servo(key="bottom");
	}
	else if (key=="bearingaxles" || key=="servogear" || key=="axle"){
		servo(key=key);
	}
}

key = "xbottom"; //, "servobottom", "axle", "bearingaxles", "servogear", "top" 
body(bodyH, bodyW, bodyT, key=key);

