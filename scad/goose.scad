use <servo_mount.scad>;
use <servos.scad>;
use <utils.scad>;
use <camera.scad>;
use <rpi_zero.scad>;
include <standards.scad>;


//camera(true);
//servo_mount_w_axle(false, servoNTooth=18, axleNTooth=18, turnAngleMiddle=90, turnArmW=9, roundtip=true, key="bottom");
//servo_mount_w_axle(false, servoNTooth=20, axleNTooth=20, turnAngleMiddle=120, turnArmW=8,  key="cut");
//axle_w_gear(GEARMODUL, 20, 180, key="buildall");

angle = 130;
servoNTooth = 15;
axleNTooth = round(180/angle*servoNTooth);

module dual_joint_arm(L, W, T=0, wallT=1){
	
	which_piece = "lower";
	
	armdirs = which_piece == "lower" ? ["up", "down"] : ["up", "up"];

	// The Radius of tip circle
	Xs = T/2;
	module servo(key="cutmild", end="right"){
		rotY = end == "right" ? 180 : 0;
		transX = end=="right" ? (L/2-Xs) : -(L/2-Xs);
		armdir = end=="right" ? armdirs[1] : armdirs[0];
		angle = armdir=="up" ? angle/2 : 180 - angle/2;
		//angle = end == "right" ? angle : 360 - angle; //angle;
		rotX = end =="right" ? -1 : 1;
		translate([transX, 0, 0])
		rotate([rotX*90,rotY,0])
		servo_mount_w_axle(false, servoNTooth=servoNTooth, axleNTooth=axleNTooth, 
				   turnAngleMiddle=angle, turnArmW=9, 
				   roundtip=true, Xs=Xs, key=key);
	}
	

	module arm_shell(key="bulk"){
		
		module arm_(wallT){
		L = L - 2*wallT;
		W = W - 2*wallT;
		T = T - 2*wallT;
		Xs = Xs - wallT;
			
		X = Xs - cornerR;
		module unit2d(){
			intersection() {
			offset(cornerR) square([2*X, W-2*cornerR], center=true);
			translate([0, -500, 0]) square(10000);
			}
		}

		module ring(){
			rotate_extrude(angle=360) translate([0, 0, -W/2]) unit2d();
		}
		
		module bulk(){
			module oneside(){rotate([0,90,0]) rotate([0,0,90]) linear_extrude(height=L-2*Xs, center=true) unit2d();}
			
			oneside();
			mirror([0,1,0]) oneside();
		}
		
		module bulkfull(){
			union(){
			for (i=[-1,1]){
				translate([i*(L/2-Xs),0, 0]) ring();
			}
			bulk();	
			}
		}
		
		bulkfull();
		}
		
		
		rotate([90, 0, 0])
		if (key=="shell"){
		difference(){
			
			arm_(0);
			arm_(wallT);
			translate([-5000, 0, -5000]) cube(10000);
			//servo(key="cutmild");
			//servo(key="cutmild", end="left");
		}
		}
		else if (key=="bulk"){	
			arm_(0);
		}
	}
	
	module cable_cutter(cableW=20, cableT=2, L_path=45, end="left"){
		tt = wallT + cableT;
		R = (pow(L_path,2) + pow(tt, 2))/(2*tt);
		corner = cableT/2;
		x = L/2 - L_path - Xs;
		i = end=="left" ? 1 : -1;
		rot = end == "left" ? 0 : 180;	
		 
		translate([i*x,0,-R + tt - T/2])
		rotate([90,0,rot]) 
		rotate_extrude(angle=90) translate([R-corner,0,0]) offset(corner) square([.001, cableW - 2*corner], center=true);
	}
	
	module rpizero_(key="cut", H=wallT+2){
		translate([0,0,-T/2]) 
		if (key=="poles"){rpizero("poles", H);}
		else if (key=="cut"){rpizero("bolts", H);}

	}
	module beam_full(topbotkey){
		module with_servo_mounts(){
			arm_shell(key="shell");
			
			intersection(){
			arm_shell(key="bulk");
			servo(key=topbotkey);
			}
			
			intersection() {
			arm_shell(key="bulk");
			servo(key=topbotkey, end="left");
			}
			if (which_piece=="lower"){
			difference(){
			rpizero_(key="poles");	
			rpizero_(key="cut");
			}
			}	
		}
		
		difference() {
			with_servo_mounts();
			servo(key="cutmild");
			servo(key="cutmild", end="left");
			cable_cutter(end="left");
			cable_cutter(end="right");
		}
	}	

	// Thickness of arm
	T = T==0 ? 2*Xs : T;

	cornerR = 3;
	topbotkey = "bottom"; //"bottom";
	beam_full(topbotkey);
}


module head(L, W, T, create="face"){
	
	R = 5;	
	// L = legth of head in nose dir:
	// W = width of head at back of the head.
	// T = height of the head at back of the head
	// alpha1 = angle by which the width cahnges
	// aplha2 = angle by which the heght changes
	// cornerR = radius of corner at back of the head:
	//
	
	wallT_ = 2;
	sp = .1;
	module bulk(R_, T=T){
		rotate([-90,0,0])
		linear_extrude(height=T) offset(R_) square([L-2*R, W-2*R], center=true);
	}
	
	module shell(wallT=wallT_, T=T){	
	difference(){
	bulk(R, T=T);
	translate([0,wallT_, 0]) bulk(R - wallT, T=T);
	
	}
	}
	
	
	module bolts(boltD){
		boltpos = [-L/6*2, 0, L/6*2];
		for (x=boltpos){ 
			for (k=[-1, 1]){
				rot = k==-1 ? 0 : 180;
				translate([x,T-4, k*W/2]) rotate([rot, 0, 0]) bolt(10, boltD, .5);
			}
		}
	}	
	module shiftedrpizero(key){
		translate([7,0,0])
		rotate([90,0,0]) rpizero(key=key, H=.5);
	}	
	module shiftedcamera(key, H){
		cameraR = 32/2;
		translate([-L/2 + 21,-H,0]) rotate([-90,0,0]) {
		camera(key, H=H);
		translate([0,0,H-7])
		difference(){
			cylinder(h=7, r=cameraR+2);	
			cylinder(h=7, r=cameraR);
		}
		}
	}
	
	module ledrow(N){
		dx = 7;
		y = T - 2*dx + 1;
		translate([2*N*dx, y, 0])
		for (i=[-N:1:N]){
			translate([i*dx, 0, 0])cylinder(h=W*2, r=3/2);
		}
	}	
	module shiftedservo(key){
		
		module shifted_(){
		translate([10, 6+1,-wallT_]) rotate([180,0,0]) 
		servo_mount_w_axle(false, servoNTooth=servoNTooth, axleNTooth=servoNTooth*1.6, turnAngleMiddle=0, turnArmW=9, roundtip=false, Xs=0, key=key, turnOverride=70, baseH=W);}

		servoNTooth = 16;
		if (key=="top"){
		intersection(){
		shifted_();
		bulk(R);
		}}
		else if (key=="bottom"){
		echo("servo");
		intersection(){
		shifted_();
		bulk(R-wallT*2-sp);
		}
		}
		else{shifted_();}
	}

	module cup(){
		
		difference(){
		union(){
		shell();	
		shiftedservo("top"); //"bottom"); //"cutmild");
		}	
		shiftedservo("cutmild"); //"bottom"); //"cutmild");

		// face attach bolts:
		bolts(BOLT3LOOSE);
		// Wire hole
		translate([0, 14+4, -W/2]) linear_extrude(W, center=true) offset(2) square([14,2], center=true);
		// Leds:
		ledrow(2);
		}
		 
	}	
		
	module face(){
		faceT = 12;
		camsink=T - 10;
		
		
		module face_(){
		translate([0,wallT_, 0])
		mirror([0,1,0])
		difference(){
			shell(wallT=2*wallT_, T=faceT);
			translate([0,faceT, 0]) mirror([0,1,0]) shell(wallT=wallT_ + .05, T= faceT-wallT_ );
			shiftedcamera(true, H=camsink);
			//shiftedrpizero("bolts");
		}
		shiftedrpizero("poles");
		shiftedcamera(false, H=camsink);
		}
		
		module shiftedface(){translate([0,T,0]) face_();}
		difference(){
		shiftedface();
		
		// Attach bolts:
		bolts(BOLT3TIGHT);
		}
		
	}
	//cup();
	if (create=="face"){face();}
	else if (create=="cup"){cup();}
	else if (create=="servobottom"){shiftedservo("bottom");}
	else if (create=="servogear"){shiftedservo("servogear");}
	else if (create=="axle"){shiftedservo("axle");}
	//shiftedservo("cutmild"); //"bottom"); //"cutmild");
	//shiftedcamera();
	//shiftedrpizero();
}

wallT = 1.5;

headW = 130;
//head(headW, 46, 33, create="face");
head(headW, 46, 30, create="cup");
//head(headW, 46, 33, create="servobottom");
//head(110, 41, 30, create="servotop");

// Beam:
//dual_joint_arm(180, 44, 25, wallT=wallT);


// Axles:
//axle_w_gear(GEARMODUL, axleNTooth, angle, turnAngleMiddle=angle/2, turnArmW=9, key="buildaxle");
//axle_w_gear(GEARMODUL, axleNTooth, angle, turnAngleMiddle=180 - angle/2, turnArmW=9, key="buildaxle");
//axle_w_gear(GEARMODUL, axleNTooth, angle, turnAngleMiddle=angle/2, turnArmW=9, key="bearingaxles");

// servo gear:
//servo_gear(GEARMODUL, servoNTooth, GEART);

// Servo mount:
//servo_mount_w_axle(false, servoNTooth=servoNTooth, axleNTooth=axleNTooth, turnAngleMiddle=angle/2, turnArmW=9, roundtip=true, Xs = 13, key="show");
//servo_mount_w_axle(false, servoNTooth=servoNTooth, axleNTooth=axleNTooth, turnAngleMiddle=angle/2, turnArmW=9, roundtip=true, Xs = 13, key="cutmild");

