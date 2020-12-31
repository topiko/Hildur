use <servo_mount.scad>;
use <servos.scad>;
use <utils.scad>;
use <electronics.scad>;
include <standards.scad>;
include <dims.scad>;

angle = 110;
servoNTooth = 15;
axleNTooth = round(180/angle*servoNTooth);

module body(L, W, T, wallT=3, key="none", R = 5){
	
	
	Xs = 13;
	topT = Xs; 
	botT = T-topT;
	attachH = 7;
	axleX = (W/2 - 22.5);
	bottomT=2;
	cornerR = 3;

	module servo(key="cutmild"){
			
		module servo_(){
			translate([axleX,0,L/2-Xs-wallT])
			rotate([0, 90,0])
			servo_mount_w_axle(false, servoNTooth=servoNTooth, axleNTooth=axleNTooth, 
				   turnAngleMiddle=(angle/2) + 20, turnArmW=9,baseH=43, 
				   roundtip=false, Xs=Xs, key=key);
		}

		module centered_mount(){
			translate([0,0,-Xs])
			rotate([-90,0,0])
			translate([-axleX, 0, -L/2+Xs+wallT])
			difference(){
				servo_();
				bodyshell(wallT=wallT+.1, key="bottom");
				bodyshell(wallT=wallT+.1, key="top");
			}
		}

		if (key=="bottom"){
			difference(){
			centered_mount();
			shiftedmpu6050();
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

	module bodyshell(wallT=wallT, key="bottom", bottomT=bottomT){
		echo(wallT);	
		sp = .04;
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
			translate([0,T, 0]) shell(L, W, T, R, wallT=wallT, bottomT=0);
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
	
	module shiftedbattery(){
		middleY = (topT - botT)/2;
		battT = 18;
		posZ = -20;
		translate([0, -botT+battT/2, posZ]) 
		rotate([0,90,0])
		battery("2S");
	}
	module motormounts(keymounts="cut"){
		
		sp = 2;
		axleD=botT - bottomT - sp*2;
		echo(axleD);
		axleR=axleD/2;
		axleH = 20;
		boltsN = 4;
		boltdedge=6;
		motorAxleY = -botT + bottomT + axleR + sp;

		dx = (W - 2*boltdedge)/(boltsN - 1) - .00001;
		module boltrow(Z){
		for (x=[-W/2+boltdedge:dx:W/2-boltdedge]){
			translate([x, -botT, Z]) rotate([-90,0,0]) bolt(T-2*wallT, BOLT3TIGHT, .0);
		}
		}
		
		module wheelaxle(Z){
			translate([0,motorAxleY,Z])
			rotate([0, 90 , 0]) cylinder(h=2*W, r=axleR, center=true);
		}
		boltsLow = 4.5;
		boltsH = 30;

		boltrow(-L/2 + boltsLow);
		boltrow(-L/2 + boltsLow + boltsH);
		wheelaxle(-L/2 + boltsH/2 + boltsLow);			
	
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
	
	module cable_cutter(cableW=20, cableT=2, L_path=45, end="left"){
		tt = wallT + cableT;
		R = (pow(L_path,2) + pow(tt, 2))/(2*tt);
		corner = cableT/2;
		z = L/2 - L_path - Xs;
		 
		translate([axleX, -R + tt - T/2,z])
		rotate([0,-90,0]) 
		rotate_extrude(angle=90) translate([R-corner,0,0]) offset(corner) square([.001, cableW - 2*corner], center=true);
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
	

	module battrack(){
		batD=18.2;
		batL=66;
		posX = 0;
		posY = -botT + bottomT;
		posZ = -17;
		T = 3;
		translate([posX, posY, posZ])
		difference(){
			translate([0, (T + bottomT)/2 - bottomT, 0]) cube([batL/3*2, bottomT + T, 3*batD], center=true);
			for (k=[-1,0,1]){
				translate([0, batD/2, k*batD]) rotate([0,90,0]) cylinder(h=batL, r=batD/2, center=true);
			}
		}
	}	
	module bottom(){
		module wadds(){
		bodyshell(key="bottom", wallT=wallT);
			
		//shiftedservocontroller(key="poles");
		shiftedmpu6050();
		battrack();
		}

		module wcuts(){
			difference(){
			wadds();
			servo("cutmild");
			//shiftedservocontroller(key="bolts");
			motormounts("cut");
			arm("cut");
			closebolts(key="bolts");
			cablecutter2();
			}
			
		}
		wcuts();
	}

	module top(){
		module wadds(){
			bodyshell(key="top", wallT=wallT);
			shiftedmicarray(key="poles");
			intersection(){
				servo("top");
				bodyshell(key="bulk", wallT=wallT);
			}	

			closebolts(key="mnts");
			shiftedservocontroller(key="poles");
			//battrack();
		}

		module wcuts(){
			difference(){
			wadds();
			servo("cutmild");
			shiftedmicarray(key="bolts");
			shiftedmicarray(key="micsleds");
			motormounts("cut");
			closebolts(key="bolts");
			bodyshell(key="cutring", wallT=wallT);
			shiftedservocontroller(key="bolts");
			}
			
		}
		//servo("cutmild");
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

key = "top"; // "bottom", "servobottom", "axle", "bearingaxles", "servogear", "top" 
body(bodyH, bodyW, bodyT, key=key);

