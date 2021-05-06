use <servo_mount.scad>;
use <servos.scad>;
use <utils.scad>;
use <electronics.scad>;
include <standards.scad>;
include <dims.scad>;



//camera(true);
//servo_mount_w_axle(false, servoNTooth=18, axleNTooth=18, turnAngleMiddle=90, turnArmW=9, roundtip=true, key="bottom");
//servo_mount_w_axle(false, servoNTooth=20, axleNTooth=20, turnAngleMiddle=120, turnArmW=8,  key="cut");
//axle_w_gear(GEARMODUL, 20, 180, key="buildall");


module head(L, W, T, create="face"){
	
	R = cornerR;	
	// L = legth of head in nose dir:
	// W = width of head at back of the head.
	// T = height of the head at back of the head
	// alpha1 = angle by which the width cahnges
	// aplha2 = angle by which the heght changes
	// cornerR = radius of corner at back of the head:
	//
	
	wallT_ = 2;
	headcuplowphi = 100; 
	servomountT = AXLEBEARINGDIMS[1] + 2;
	hornarmL = servomountT/2 - 1; //*sin(turnphi-lowphi) + 5;
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
		boltpos = [-L/2*.8, 0, L/2*.8];
		for (x=boltpos){ 
			for (k=[-1, 1]){
				rot = k==-1 ? 0 : 180;
				translate([x,T-4, k*W/2]) rotate([rot, 0, 0]) bolt(6, boltD, .2);
			}
		}
	}	
	module shiftedrpizero(key){
		sX = L/2 - 65/2 - wallT_ - 4;  
		H = 6;
		translate([sX, wallT_, 30/2 - W/2 + 2*wallT_  +2])
		rotate([90,0,0]) rpizero(key=key, H=H+wallT_, T=10);
	}	


	module shiftedcamera(key, H){
		cameraR = 32/2;
		cameraW = 38;
		sX = (-L + cameraW)/2 + wallT_ + 12.5;

		translate([sX,-H,0]) rotate([-90,0,0]) {
			camera(key, H=H);
			translate([0,0,H-7])
			difference(){
				cylinder(h=7, r=cameraR+2);	
				cylinder(h=7, r=cameraR);
			}
		}
	}
	

	module shiftedservo(key){
		turnphi = 110;
		lowphi = headcuplowphi; //100;
		mountT = servomountT;
		
		phimiddle = 270-lowphi + turnphi/2;	
		echo("Head horn arm L: ", hornarmL);
		module shifted_(){
			translate([neckX, 0, -W/2+wallT_]) 
			mirror([1,0,0])
			rotate([0,90,0]) 
			servo_mount_aligned(key=key, servoNtooth=SERVOGEARNTOOTH, 
					    turnAngle=turnphi, armAngleMiddle=phimiddle, 
					    axlehornDin=AXLEHORNDIN, type=2, T=mountT,
					    hornarmL=hornarmL, threadhandness="left");
		}


		if (key=="top"){
			intersection(){
				shifted_();
				bulk(R - wallT_- .1); // - wallT*2);
			}
		}
		else if (key=="bottom"){
			intersection(){
				shifted_();
				bulk(R);
			}
		}
		else{shifted_();}
	}

	//shiftedservo("top");
	module cup(){
		
		difference(){
		union(){
			shell();	
			shiftedservo("bottom"); //"bottom"); //"cutmild");
		}
			
		// usb charge:
		translate([0,T,0]) shiftedrpizero("cuts");
		
		// servo openings:
		shiftedservo("cut"); //"bottom"); //"cutmild");
		
		// Cut for usb charging:
		shiftedrpizero("cutusb");

		// face attach bolts:
		bolts(BOLT3LOOSE);
		
		// Wire hole
		translate([-6, -T/3, +9 +wallT_ - W/2]) rotate([90,0,0]) linear_extrude(W, center=true) offset(2) square([2,14], center=true);
		
		// Leds:
		// ledrow(2);
		}
		 
	}	
		
	module face(){
		faceT = 13;
		camsink=T - 10;
		
		
		module face_(){
			shiftedrpizero("poles");
			translate([0,wallT_, 0])
			mirror([0,1,0])
			difference(){
				shell(wallT=2*wallT_, T=faceT);
				translate([0,faceT, 0]) mirror([0,1,0]) shell(wallT=wallT_ + TIGHTSP, T= faceT-wallT_ );
			}
		}	
		module wcuts_(){
			difference(){
			face_();
			shiftedcamera(true, H=camsink);
			shiftedrpizero("bolts");
			shiftedrpizero("cuts");
			
			}

		shiftedcamera(false, H=camsink);
		}

		
		module shiftedface(){translate([0,T,0]) wcuts_();}
		difference(){
		shiftedface();
		
		// Attach bolts:
		bolts(BOLT3TIGHT);
		}
		
	}

	if (create=="face"){face();}
	else if (create=="cup"){cup();}
	else if (create=="axleparts"){shiftedservo("axleparts");}
	else if (create=="rpi"){translate([0,T,0]) shiftedrpizero("boardpoles");}
	else if (create=="servobottom"){shiftedservo("bottom");}
	else if (create=="servotop"){shiftedservo("top");}
	else if (create=="servomockup"){shiftedservo("mockup");}
	else if (create=="servogear"){shiftedservo("servogear");}
	else if (create=="axle"){shiftedservo("axle");}
	else if (create=="bearingaxles"){shiftedservo("bearingaxles");}
	else if (create=="mockup"){
		translate([0,-7, 0]){
		bulk(R, T=T);
		shiftedcamera(true, H= -10);
		}
	}
	else if (create=="neck"){
		neckcurve(headcuplowphi, servomountT, hornarmL=hornarmL);
	}
	
}

module neckcurve(headcuplowphi, mountT, hornarmL=LHORNTHREAD, axlehornDin=AXLEHORNDIN){
	
	headlowphi = 40; 
	theta = -(headcuplowphi - 90) + headlowphi;

	
	//   | .   c
	// a |     .
	//   |_________.
	//        b
	
	ahead = 6 + AXLEBEARINGDIMS[1]/2; // These come from servo mount...
	bhead = headT - mountT/2; //AXLEBEARINGDIMS[1]/2 + 1;  // The latter is the servo mountT from head.
	thetahead = atan(ahead/bhead);
	chead = sqrt(pow(ahead, 2) + pow(bhead,2));
	
	needed_chin_space = chead*sin(headlowphi + thetahead) - ahead;
	echo("Required chin space: ", needed_chin_space);

	Rneck = AXLEBEARINGDIMS[0]/2 + AXLECOVERT;
	R = 2;
	showaligner=SHOWALIGNERS; //true;"show"; //
	//RADSP = .2;	

	module cylwthread(key, L, phi=0){
		
		D = AXLEHORNDIN + 2*RADSP;
		if (key=="cyl"){
			difference(){
				cylinder(h=L, r=Rneck);
				thread(LHORNTHREAD + 1, D, aligner=showaligner, phi=-phi, dtip2=D, dtip1=D);
				thread(LHORNTHREAD + 1, D, aligner="onlyaligner", phi=0, dtip2=D, dtip1=D);
			}
		}
		else if (key=="thread"){
			thread(LHORNTHREAD + 1, D, aligner=showaligner, phi=-phi);
		}

	}
	
	module curve(){
	
		translate([-R-Rneck, 0])
		rotate([90,0,0])
		rotate_extrude(angle=theta)
		translate([R+Rneck,0]) circle(r=Rneck);
	}

	module cylinders(key="cyl"){
		translate([0,0,-L1]) cylwthread(key, L1, phi=phi1);
		translate([-R-Rneck,0,0]) rotate([0,-theta,0]) translate([R+Rneck,0,L2]) rotate([0,180,0]) cylwthread(key, L2, phi=phi2);
	}


	L1 = 12;
	L2 = ahead - hornarmL + 1;
	phi1 = 90; // bottom 35
	phi2 = 90; // top 35
	translate([0,0,L1-3]){
		difference(){
			curve();
			cylinders("thread");
		}
		cylinders("cyl");
	}
	
	
}

//wallT = 1.5;

//head(headW, headL, headT, create="cup");
//head(headW, headL, headT, create="face");
//head(headW, headL, headT, create="servomockup");
//head(headW, headL, headT, create="axle");
//translate([0,40,0]) head(headW, headL, headT, create="servotop");
//translate([0,0,20]) head(headW, headL, headT, create="neck");
head(headW, headL, headT, create="axleparts");

module tests(){
	translate([0,10,0]) head(headW, headL, headT, create="servotop");
	head(headW, headL, headT, create="servobottom");
	translate([0,0,70]) head(headW, headL, headT, create="axleparts");
}


//tests();


