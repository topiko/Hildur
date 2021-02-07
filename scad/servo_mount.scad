use <gears/gears.scad>;
use <servos.scad>;
use <utils.scad>;
include <standards.scad>;
include <dims.scad>;

module wedge(H, R, phi, R2=100, roundedge=false){
		
	addAngle = asin(R/R2);
	phi = phi/2 + 2*addAngle;

	module cutter(i){
		if (roundedge){
			rotate([0,0,i*(phi-addAngle) ])	
			translate([-R,i*R,H/2])
			rotate([0,90,0])
			difference(){
				translate([0,0,R2])cube([H,H,2*R2], center=true);
				translate([0, -i*H/2,0])cylinder(h=2*R2, r=H/2);
			}
		}
	}
	
	module side(i){
		hull(){
			cylinder(h=H, r=R);
			rotate_extrude(angle=i*phi) square([R2, H]);
		}
	}
	
	if (roundedge){	
		difference(){	
			for (i=[-1,1]){rotate([0,0,-i*addAngle]) side(i);}
			for (i=[-1,1]){rotate([0,0,-i*addAngle]) cutter(i);}
		}
	}
	else {for (i=[-1,1]){rotate([0,0,-i*addAngle]) side(i);}}
}

module servo_mount_aligned(key="bottom", servoNtooth=SERVOGEARNTOOTH, turnAngle=180, armAngleMiddle=90, axleNtooth=0, H=0, T=0, W=0, axleL=20, type=3, axlehornDin=7, bearingdims=AXLEBEARINGDIMS, axlecoverT=.64, hornarmL=20, addXR=6, addXL=6, boltkey="csunk"){
	
	axleNtooth = axleNtooth == 0 ? ceil(servoNtooth/turnAngle*150) : axleNtooth;
	pitchD1 = pitchD(servoNtooth, GEARMODUL); 
	pitchD2 = pitchD(axleNtooth, GEARMODUL); 
	axleX = (pitchD1 + pitchD2)/2;

	gearSp = .1;	

	addX = addXL + addXR;
	addY = 1;
	addZ = 1;
	servodims = mg215dims;

	axleD = type==1 ? servodims[2] : 
		(type==2 || type==3 || type==4) ? min(servodims[2], bearingdims[0]) : 
		type==5 ? bearingdims[0] : 
		100;

	axlehornDout = axlehornDout(axleD, axlecoverT);

	axleL = type==1 ? servodims[1] - SERVOHORNSP - SERVOHORNBEARINGT : 
		type==2 ? SERVOHORNSP + bearingdims[2]*2 + axlehornDout + 4*SERVOHORNSP : 
		type==3 || type==4 || type==5 ? axleL : 
		0;
	
	mountWx = W!=0 ? W :
		  type==1 ? servodims[0] + (pitchD1/2-servodims[3]) + pitchD2/2 + axleD/2 + addX: 
		  type==2 || type==3 || type==5 ? servodims[3] + addXL + pitchD1/2 + pitchD2/2 + bearingdims[1]/2 + addXR: 
		  type==4 ? servodims[0] - servodims[3] + pitchD1/2 + pitchD2/2 + bearingdims[1]/2 + addX:
		  W;
	echo("Servo mount Wx = ", mountWx, type);

	mountTy = T==0 ? bearingdims[1] + addY: T;
	mountHz = H!=0 ? H : 
		  type==1 ? servodims[1] + SERVOHORNT + SERVOHORNBEARINGT + SERVOHORNSP*3 + addZ :
    		  type==2 || type==3 || type==4 ? servodims[1]/3*2 + axleL + SERVOHORNT + 2*SERVOHORNSP : 
		  type==5 ? servodims[1]/3*2 + axleL + SERVOHORNT + SERVOHORNSP : 
		  H;

	echo("Servo mount Hz = ", mountHz + servodims[1]/3);
	shiftX = type==1 ? -mountWx - servodims[3] + servodims[0] + addXR : 
		 type==2 || type==3 || type==5 ? - servodims[3] - addXL :
       		 type==4 ?  -(pitchD1/2+pitchD2/2 + bearingdims[1]/2 + addXL): 0; //-(pitchD1-6) - pitchD2;
	shiftZ = type==1 ? -servodims[1] :
		 type==2 || type==3  || type==4 || type==5 ? -servodims[1]/3*2 : 
		 0; 

	axlehornZ = SERVOHORNT + axleL/2 + SERVOHORNSP/2;

	module servo(key){
		kst_mg215_servo(key, hornT=SERVOHORNT, ntooth=servoNtooth, hornSp=SERVOHORNSP, topBearing=true);
	}

	module mount_bulk(key){
			
		module side(){
			translate([shiftX, 0, shiftZ])
			cube([mountWx, mountTy/2, mountHz]);
		}

		module cablecutter(){
			R = axleD/4; //axleD/2;
			translate([axleX + axleD/2 - R, 0, 0])
			rotate([-90,0,0])
			union(){
				cylinder(h=mountTy, r=R);
				sphere(r=R);
			}
		}

		if (key=="bottom"){
			difference(){
				mirror([0,1,0]) side();
				cut();
				if (type==5){cablecutter();}
			}
			
		}
		else if (key=="top"){
			difference(){
				side();
				cut();
				if (type==5){cablecutter();}
			}

		}

	}
	
	module closebolts(boltD=BOLT25LOOSE){
		//boltD = BOLT25LOOSE;

		boltD = key == "top" ? BOLT25LOOSE :
			key == "bottom" || key=="cut" ? BOLT25TIGHT :
			boltD;
		boltdist = 2.5;
		boltdist2 = 2.0;
		boltXL =  -(pitchD1/2 + pitchD2/2 + bearingdims[1]/2 + boltdist);
		boltXR = servodims[0] - servodims[3] + boltdist;
		boltX1 =  -(servodims[3] + (pitchD1 + pitchD2)/2 - bearingdims[0]/2)/2;
		boltX2 = bearingdims[1]/2 + boltdist;
		boltX3 = -axleX/2;
		boltX4 = -(servodims[3] + boltdist);
		boltX5 = (SERVOBEARINGDIMS[1]/2 + (axleX-bearingdims[1]/2))/2; 
		boltX6 = (axleX + bearingdims[1]/2 + boltdist2); 

		topbolthz = SERVOHORNT + 1*SERVOHORNSP + bearingdims[2]/2 + addZ;	
		topbolthz2= SERVOHORNT + axleL - bearingdims[2]/2;	
		botbolthz = type==1 ? -axleL - bearingdims[2]/2 + SERVOHORNSP: -servodims[1]/2;

		boltposbot = (type==1) ? [boltXR, boltX1, boltXL] :  [boltXR, boltX4];
		boltposservo = (type==1) ? [boltXR, mountTy/2, 0] : [boltXR, mountTy/2, -3];
		boltpostop = (type==1) ? [boltX2, boltX3, boltXL] : [boltX5, boltX6, boltX4];
		boltpostop2 = [boltX5, boltX6];
		R1z = 0;

		//sink = 0;
		sink = type!= 5 ? max(mountTy/2 - 8, .4) : mountTy/2 - 12;
			
		boltL = mountTy-boltD/2 - sink - .2;
		
		for (x=boltpostop){translate([x, mountTy/2, topbolthz]) rotate([90,0,0]) bolt(boltL, boltD, sink, key=boltkey);}
	
		for (x=boltposbot){translate([x, mountTy/2, botbolthz]) rotate([90,0,0]) bolt(boltL, boltD, sink, key=boltkey);}
		
		if (type==2 || type==3){
			for (x=boltpostop2){translate([x, mountTy/2, topbolthz2]) rotate([90,0,0])  bolt(boltL, boltD, sink, key=boltkey);}
		}	
		translate(boltposservo) rotate([90,0,0]) bolt(boltL, boltD, sink, key=boltkey);
	}
	
	module axle(key){
		//D = (pitchD1 + pitchD2)/2;
		module axle_(){
			turn_axle(key, axleNtooth, turnAngle, armAngleMiddle, axleD=axleD, axleL=axleL, axlehornZ=axlehornZ, axlehornDin=axlehornDin, type=type, coverT=axlecoverT, hornarmL=hornarmL, bearingdims=bearingdims);}
		if (type==1){
			translate([-axleX, 0, SERVOHORNT + SERVOHORNSP])
			rotate([180,0,0]) axle_();
		}
		else if (type==2 || type==3 || type==5){
			rotate([0,0,180])
			translate([-axleX, 0, SERVOHORNSP])
			axle_();
		}
		else if (type==4){
			rotate([0,0,180])
			translate([axleX, 0, SERVOHORNSP])
			rotate([0,0,180])
			axle_();
		}
	}
	

	module cut(){
		axle("cut");
		servo("cut");
		closebolts();	
	}
	
	move =  type==2 ? [-shiftX - mountWx, mountTy/2, -axlehornZ] :
		type==3 || type==5 ? [-axleX, mountTy/2, -shiftZ - mountHz] : 
		[0,0,0] ;

	translate(move)
	if (key=="bottom" || key=="top"){
		mount_bulk(key);
	}
	else if (key=="servogear"){servo("servogear");}
	else if (key=="mockup"){
		mount_bulk("bottom");
		axle("mockup");
		servo("mockup");
		closebolts();	
	}	
	else if (key=="cut"){cut();}
	else if (key=="axleparts"){
		axle("axle");
		translate([0,40,0]) servo("servogear");
		if (type==1){translate([20,0,0]) axle("bearingaxle");}	
		if (type==2 || type==3 || type==5){translate([30,0,0])axle("cover");}
		if (type==2 || type==3){translate([0,20,0]) axle("hornarm");}
	}
	//axle("cut");
}

module turn_axle_wheel(key, ntooth, turnAngle, turnAngleMiddle, axleD=12, axleL=20, axlehornDin=8, axlehornZ=15, bearingdims=AXLEBEARINGDIMS, type=1, hornarmL=15, coverT=.64){
	
	turn_axle(key, ntooth, turnAngle, turnAngleMiddle, axleD=12, axleL=20, axlehornDin=8, axlehornZ=15, bearingdims=AXLEBEARINGDIMS, type=5, coverT=.64);
}

module turn_axle(key, ntooth, turnAngle, turnAngleMiddle, axleD=12, axleL=20, axlehornDin=8, axlehornZ=15, bearingdims=AXLEBEARINGDIMS, type=1, hornarmL=15, coverT=.64){
	
	axleD = (type==2 || type==3 || type==4 || type==5) ? bearingdims[0] - TIGHTSP/2 : axleD;
	//axlehornZ = type==2 ? axlehornZ - 2*TIGHTSP : axlehornZ;
	braxleL = SERVOHORNT/2;
	hornarmR = axlehornDout(axleD, coverT)/2;

	module axlehorn(key){
		R = axlehornDin/2 - TIGHTSP;
		translate([0,0,axlehornZ])
		rotate([0,0,-turnAngleMiddle])
		if (key=="axle"){
			rotate([0,90,0])
			cylinder(h=2*axleD, r=R, center=true);}
		else if (key=="cut"){
			addR = type==1 ? SERVOHORNSP : 2*SERVOHORNSP;
			R = axleD/2 + addR;
			H = type==1 ? R + 2*SERVOHORNSP : 
			    type==2 ? hornarmR*2+ SERVOHORNSP*2 : 0;
			translate([0,0, -H/2]) wedge(H, R, turnAngle, roundedge=true);
			echo(axleD, H, axleL, bearingdims[2], axlehornZ);
		}
		else if (key=="mockup"){
			/*translate([0,0,axlehornZ])
			rotate([0,0,turnAngleMiddle])*/ 
			rotate([0,0,90]) 
			rotate([-90,0,0]) 
			rotate([0,0,90]) 
			translate([0,0,-hornarmL]) hornarm();
		}
	}
	module hornarm(){
		R = type==1 ? axleD/2 : type==2 ?  axleD/2 + coverT : 0;	

		module axle_(addR){
			translate([0,0,hornarmL]) rotate([0,90,0]) cylinder(h=2*axlehornDin, r=R + addR, center=true);
		}
		
		if (type==1 || type==2){
		
		needleR =  axlehornDin/2-2*TIGHTSP;
		// needle - goes into axle:
		intersection(){
			cylinder(h=hornarmL + R, r=needleR);
			axle_(0);
		}
		// arm
		difference(){
			union(){
				difference(){
					cylinder(h=hornarmL, r=hornarmR);
					axle_(TIGHTSP*2);
				}
				cylinder(h=hornarmL, r=needleR);
			}
			cylinder(h=hornarmL/2, r=axlehornDin/2+TIGHTSP);
			}
		}
	}

	module axlecyl(key){
		axleD = key != "cut" ? axleD : 
			type ==1 ? axleD + 2*SERVOHORNSP : 
			axleD + 4*SERVOHORNSP;

		axleL = type==4 && key =="cut" ? axleL+hornarmL: 
			type==2 && key=="cut" ? axleL+SERVOHORNSP : 
			type==3 || type==5 ? axleL+hornarmL :
			axleL;

		if (key=="cut"){
			cylinder(h=axleL + SERVOHORNT, r=axleD/2);
		}
		else {
			if (type==1){cylinder(h=axleL + SERVOHORNT, r=axleD/2);}
			else if (type==2){cylinder(h=axleL + SERVOHORNT, r=axleD/2);}
			else if (type==3){
				difference(){
					cylinder(h=axleL, r=axleD/2);
					translate([0,0,axleL/2]) cylinder(h=axleL, r=axlehornDin/2+TIGHTSP);
				}
			}
			else if (type==4){cylinder(h=axleL + SERVOHORNT, r=axleD/2);}
			else if (type==5){
				difference(){
					cylinder(h=axleL, r=axleD/2);
					cylinder(h=axleL, r=axlehornDin/2);
				}
			}
		}
		//gearkey = key == "axle" ? "gear" : 
		//	  key == "cut" ? "cut" : 
		//	  key=="mockup" ? "gear" : 
		//	  "none";
		//
		//gear(gearkey);
	}

	module axle(key){
		
		module modaxle(key, gearkey, choose){

			module joiner(H, sp){
				linear_extrude(height=H, twist=H/3*360, convexity = 10, slices=round(H/.15))
				translate([hthread, 0, 0]) 
				circle(rscrew + sp);
				//circle(axleD/2 - hthread - wJ - sp);
				//cylinder(h=H, r=axleD/2 - wJ + sp, $fn = 8);
			}
			
			H = SERVOHORNT + TIGHTSP;
			hthread = .3;
			//rscrew  = (axleD + axlehornDin)/4 + hthread/2;
			//2*rscrew - hthread = axlehornDin + (axleD - axlehornDin)/3;
			//2*rscrew + hthread = axlehornDin + (axleD - axlehornDin)*2/3;
			rscrew = (axlehornDin + axleD)/4;
			echo("Thinnest wall in servo arm axles: ", (axleD- axlehornDin)/6);
	
			if (choose=="axle"){
				difference(){
					axlecyl(key);
					cylinder(h=H, r=100000);
				}
				intersection(){
					axlecyl(key);
					joiner(H, 0);
				}	
			}
			else if (choose=="gear"){
				difference(){
					gear(gearkey);
					translate([0,0, H]) cylinder(h=10000, r=20000);
					joiner(H, 2*TIGHTSP);
				}
			}

		}
		module axle_(key){
			gearkey = key == "axle" ? "gear" : 
			  	  key == "cut" ? "cut" : 
			   	  key=="mockup" ? "gear" : 
			  	  "none";
		

	  		color(GEARCOLOR)		
			if (type==1){
				if (key=="cut"){
					axlecyl(key);
					translate([0,0, braxleL]) mirror([0,0,1]) bearingaxle(key, braxleL);
					translate([0,0, axleL + SERVOHORNT - braxleL]) bearingaxle(key, braxleL);}
				
				else if (key=="axle" || key=="mockup"){
					difference(){	
						axlecyl(key);
						axlehorn("axle");
						translate([0,0, braxleL]) mirror([0,0,1]) bearingaxle("cut", braxleL);
					}
				if (key=="mockup"){
					translate([0,0, braxleL]) mirror([0,0,1]) bearingaxle(key, braxleL);
				}
				
				// Create gear:
				gear(gearkey);
				translate([0,0, axleL + SERVOHORNT - braxleL]) bearingaxle(key, braxleL);
				}
			}
			else if (type==2){
				if (key=="cut"){
					axlecyl(key);
				}
				else if (key=="axle"|| key=="mockup"){
					difference(){
						axlecyl(key);
						axlehorn("axle");
					}

				gear(gearkey);
				}
			}
			else if (type==3 || type==4 || type==5){
				if (key=="cut" || key == "mockup"){
					axlecyl(key);
					gear(gearkey);
				}
				else if (key=="axle"){
					modaxle(key, gearkey, "axle");
					translate([40,0,0]) modaxle(key, gearkey, "gear");
					//axlecyl(key);

				}
			}
		}
		

		module cover(){
			difference(){
				translate([0,0,SERVOHORNT]) cylinder(h=axleL, r=axleD/2 + coverT);
				cylinder(h=50*axleL, r=axleD/2 + 2*TIGHTSP);
				if (type==2){axlehorn("axle");}
				bearings("mockup");
			}
		}

		axle_(key);

		// TYPE 1:
	  	color(GEARCOLOR)		
		if (type==1){
			if (key=="cut"){
				//translate([0,0,-SERVOHORNSP]) 
				mirror([0,0,1]) bearing("cut");
				translate([0,0, axleL + SERVOHORNT]) bearing("cut");
				axlehorn("cut");
				
			}
			else if (key=="bearingaxle"){
				bearingaxle("axle", braxleL-TIGHTSP);
			}
			else if (key=="mockup"){
				//axle_("axle");	
				axlehorn(key);
				translate([0,0,-SERVOHORNSP]) 
				mirror([0,0,1]) bearing("mockup");
				translate([0,0, axleL + SERVOHORNT + SERVOHORNSP]) bearing("mockup");
				translate([0,0, braxleL]) mirror([0,0,1]) bearingaxle("cut", braxleL);
			}
		}
		// TYPE 2 and 3:
		else if (type==2 || type==3 || type==4 || type==5){
			if (key=="cut" || key=="mockup"){
				bearings(key);
				cover();
				if (type==2){axlehorn(key);}
			}
			else if (key=="cover"){cover();}
		}		


	}

	module gear(key){
			
		H = SERVOHORNT; 
		R = axleD/2;
		gearBore = type==5 ? axlehornDin :
			   0;	

		color(GEARCOLOR)
		if (key=="gear"){
			k = type==1 ? 1 : -1;
			intersection(){
				wedge(H, R, turnAngle);
				herringbone_gear(GEARMODUL, ntooth, SERVOHORNT, 
					   	gearBore, 
					   	pressure_angle=20, 
					   	helix_angle=k*HELIXANGLE, 
					   	optimized=false);

			}
		}
		else if (key=="cut"){
			H = H + SERVOHORNSP*2;
			addR = type==1 ? SERVOHORNSP : 2*SERVOHORNSP;
			R = R + addR;
			R2 = gearD(ntooth, GEARMODUL)/2 + SERVOHORNSP;
			translate([0,0, -SERVOHORNSP]) wedge(H, R, turnAngle*2, R2=R2);
		}
	}
	
	module bearing(key){
		H = bearingdims[2]; //+ TIGHTSP;
		addH = key=="cut" ? type==1 ? SERVOHORNSP : 
		       type==2 || type==3 || type==4 || type==5 ? 2*TIGHTSP : 
		       10 : 0;

		R = bearingdims[1]/2 + TIGHTSP;
		color(BEARINGCOLOR)
		cylinder(h=H+addH, r=R);
		//if ((key=="cut" || key=="mockup")){cylinder(h=H+addH+1, r=bearingdims[0]/2 + 1);}
	} 
	
	module bearings(key){	
		translate([0,0, SERVOHORNT + SERVOHORNSP]) bearing(key);
		translate([0,0, axleL + SERVOHORNT - bearingdims[2]]) bearing(key);
	}
	module bearingaxle(key, L){
		sp = key=="cut" ? TIGHTSP : 0;
		H = bearingdims[2] + L + SERVOHORNSP;
		r2 = bearingdims[0]/2 + .7 - sp;
		cylinder(h=H, r=bearingdims[0]/2 - TIGHTSP);
		cylinder(h=H - bearingdims[2], r=r2);
		if ((key=="cut" || key=="mockup") && type==1){
			translate([0,0,H]) cylinder(h=2*SERVOHORNSP, r=r2);
		}
	}

	if (key=="mockup"){	
		//gear("gear");
		axle("mockup");
	}
	else if (key=="axle"){
		//gear("gear");
		axle("axle");
	}
	else if (key=="cut"){
		//gear("cut");
		axle("cut");
	}
	else if (key=="cover"){
		axle("cover");
	}
	else if (key=="bearingaxle"){
		bearingaxle("bearingaxle", braxleL);
	}
	else if (key=="hornarm"){
		hornarm();
	}

}

function axlehornDout(axleD, coverT) = axleD + coverT*2;
//$fn = 30;
//$fa = 10;
//$fs = .10;

//servo_mount_w_axle(false, servoNTooth=14, axleNTooth=26, key="bottom");
//servo_mount_w_axle(false, servoNTooth=14, axleNTooth=26, key="top");
//servo_mount_w_axle(false, servoNTooth=14, axleNTooth=26, key="cut");
//servo_mount_w_axle(true, true);
//axle_w_gear(GEARMODUL, 26, 90, key="buildall");
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
type=3;
axleL = 12;
axlehornDin=3;
hornarmL=0;
key="axleparts"; //"mockup"; //"mockup"; //"cut"; //"axleparts"; //"cut"; //"axleparts"; //"cut"; //axleparts"; //"mockup";//"mockup"; //"cut"; //"mockup"; // "mockup";// "cut";
//servo_mount_aligned(key="cut", servoNtooth=SERVOGEARNTOOTH, turnAngle=90, armAngleMiddle=250, axleL=axleL, axleNtooth=SERVOGEARNTOOTH+5, type=type);
//servo_mount_aligned(key=key, servoNtooth=SERVOGEARNTOOTH, turnAngle=90, armAngleMiddle=250, axleL=axleL, axleNtooth=SERVOGEARNTOOTH+5, axlehornDin=axlehornDin, type=type, hornarmL=hornarmL);


mirror([1,0,0]) servo_mount_aligned(key=key, servoNtooth=SERVOGEARNTOOTH, turnAngle=110, armAngleMiddle=250, axleL=axleL, axlehornDin=axlehornDin, type=type, hornarmL=hornarmL);


//servo_mount_aligned(key=key, servoNtooth=22, turnAngle=120, armAngleMiddle=250, axleL=10, axlehornDin=WHEELBEARINGDIMS[0]-3, type=type, hornarmL=hornarmL, bearingdims=WHEELBEARINGDIMS);

//servo_mount_aligned(key=key, servoNtooth=22, turnAngle=110, axleL=10, bearingdims=WHEELBEARINGDIMS, axlehornDin=WHEELBEARINGDIMS[0]- 5, type=5, hornarmL=hornarmL);

//translate([10,0,0])servo_mount_aligned(key="cut", servoNtooth=22, turnAngle=120, armAngleMiddle=250, axleL=axleL, axlehornDin=axlehornDin, type=type, hornarmL=hornarmL, bearingdims=WHEELBEARINGDIMS);
//servo_mount_aligned(key="cut", servoNtooth=SERVOGEARNTOOTH, turnAngle=90, armAngleMiddle=90, axleNtooth=0, H=0, T=0, W=0);
//turn_axle("mockup", 26, 90, 40, axleD=12, axleL=20);

//turn_axle_wheel("key", axlehornDin=8);
//wedge(10, 12, 100, R2=100, roundedge=true);
