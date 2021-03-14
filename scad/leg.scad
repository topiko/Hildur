use <utils.scad>;
use <body.scad>;
include <standards.scad>;
include <dims.scad>;
use <gears/gears.scad>;

module gear(ntooth, T, bore=0, k=1){

	herringbone_gear(GEARMODUL, ntooth, T, 
			 bore, 
			 pressure_angle=20, 
			 helix_angle=k*HELIXANGLE, 
			 optimized=false);


}
module plate(D1, D2, D, H, wt=0, sw=0){


	module bulk_(H=H, substR=0){
		hull(){
			cylinder(h=H, d=D1-2*(sw+substR));		
			translate([D, 0, 0]) cylinder(h=H, d=D2-2*(sw+substR));		
		}
	}


	difference(){
		bulk_();
		if (wt!=0){translate([0,0,-1]) bulk_(2*H, wt);}
	}
}
	
module wheel_disk(T, R, r0, bore=0, key="wheel", wheelSp=1.){
		

	
	if (key=="wheel"){
		x = r0*(1-sin(30));
		rotate_extrude(angle=360)
		difference(){
			translate([bore/2, -T/2]) square([R-2*r0-bore/2+x, T]);
			translate([R-r0, 0]) circle(r=r0);
		}
	}
	else if (key=="tyre"){
		color("Gray")
		rotate_extrude(angle=360) translate([R-r0, 0]) circle(r=r0);
	}
	else if (key=="cut"){
		r0 = r0+wheelSp;
		R = R+1;	
		cylinder(h=2*r0, r=R-r0+wheelSp, center=true);	
		rotate_extrude(angle=360)
		translate([R-r0+wheelSp, 0]) circle(r0);
		echo("cut wheel D = ", 2*(R-r0+wheelSp + r0), 2*R);
		
	}
	
	
}

module pololu_motor(key="motor", Lmount=0, firewallT=0){
	W = 10;
	L = 25;
	D = 12;
	
	Daxle = 3;
	Laxle=10;
	daxlecut = .5;
	wallT=1;
	module motorshape_(L=L, D=D, W=W, wallT=0){
		linear_extrude(height=L) offset(1) square([10+2*wallT, 8+2*wallT], center=true);
		/*	
		intersection(){ 
			cube([100, W, 2*L], center=true);
			cylinder(h=L, d=D);
		}
		*/
	}
	module motor(sp=0){
		intersection(){ 
			cube([100, W+2*sp, 2*L], center=true);
			cylinder(h=L, d=D + 2*sp);
		}
	}

	if (key=="motor" || key=="cutbearing" || key=="cutmotor" || key=="cutaxle"){
		sp = key == "cutbearing" ? TIGHTSP : 
		     key == "cutaxle" ? TIGHTSP :
		     key == "cutmotor" ? .3 : 0;
		// axle
		difference(){
			cylinder(h=Laxle, d=Daxle+2*sp);
			translate([2*Laxle + Daxle/2 - daxlecut-sp, 0 ,0])cube(4*Laxle, center=true);
		}
		// motor
		translate([0,0,-L]) motor(sp);
		// gearbox
		translate([0,0,-9]) motorshape_(9, wallT=sp);
		// bearing
	//	if (key=="motor" || key=="cutbearing"){
	//		translate([0,0, Laxle-SERVOBEARINGDIMS[2]]) cylinder(h=SERVOBEARINGDIMS[2], d=SERVOBEARINGDIMS[1] + 2*sp);
	//	}
	}
	else if (key=="mount" || key=="cutmount"){
		sp = key == "cutmount" ? 1.5*TIGHTSP : 0;
		wallT = 1;
		
		color("Gray")
		translate([0,0,-Lmount])
		difference(){
			motorshape_(Lmount+firewallT, wallT=wallT+sp); // D=D+2*(wallT+ sp), W=W+2*(wallT+sp));
			
			// Space inside:
			if (key!="cutmount"){
				motorshape_(Lmount, wallT=2*TIGHTSP); //D=D+2*TIGHTSP, W=W+2*TIGHTSP);}

				// Axle
				cylinder(h=3*Lmount, d=4.2, center=true);
				// Attaach bolts:
				for (x=[-4.5, 4.5]){
					translate([x, 0, Lmount+firewallT]) mirror([0,0,1]) bolt(Lmount, 1.65, -1., key="flat");
				}
			}
		}
	}

}


module wheel(key, legside="right"){
	
	wheelSp = .5;

	BEARINGDIMSWHEEL = SERVOBEARINGDIMS;
	bearingoutRsp = TIGHTSP/5*3;
	bearinginRsp = TIGHTSP/2;
	boltsink = .3;
	bearingAxleD = SERVOBEARINGDIMS[0]-2*bearinginRsp;

	threadhandness = legside == "left" ? "right" : "left";

	module gear_wheel_(bearingdims=BEARINGDIMSWHEEL){
		difference(){
			translate([0, 0, gearDwheelcenter]) gear(ntoothwheel, gearT);
			wheel_(RADSP);
			cylinder(h=10000, d=bearingdims[1]+2*bearingoutRsp, center=true);
		}
	}
	module gear_motor_(key="gear"){
		translate([0, 0, gearDwheelcenter])
		if (key=="gear"){
		difference(){
			union(){
			gear(ntoothmotor, gearT, k=1);
			cylinder(h=gearT+.3, d=SERVOBEARINGDIMS[0]+2);
			cylinder(h=gearT+SERVOBEARINGDIMS[2], d=SERVOBEARINGDIMS[0]-2*bearinginRsp); //TIGHTSP);
			}
			pololu_motor(key="cutaxle");
		}
		}
		else if (key=="bearing"){
			translate([0,0,gearT + .3])
			cylinder(h=SERVOBEARINGDIMS[2], d=SERVOBEARINGDIMS[1]+2*bearingoutRsp); //2*TIGHTSP);
		}
	}
	module gear_gear_(key="gear"){
		if (key=="gear"){
			translate([0, 0, gearDwheelcenter])
			gear(ntoothgear, gearT, bore=SERVOBEARINGDIMS[1]+TIGHTSP, k=-1); //bearingoutRsp*2, k=-1);
		}
		else if (key=="axle"){
			translate([0, 0, gearDwheelcenter]){
			difference(){
			union(){
			cylinder(h=SERVOBEARINGDIMS[2], d=bearingAxleD);
			translate([0,0, -2]) cylinder(h=2, d=SERVOBEARINGDIMS[0]+ 2);
			}
			cylinder(h=1000, d=BOLT25TIGHT);
			}
			}
		}
		else if (key=="spacer"){
			translate([0,0, gearDwheelcenter+gearT]) // outerwallD])
			cylinder(h=outerwallD, d=SERVOBEARINGDIMS[0]+2);
		}
		else if (key=="bolt"){
			boltD = BOLT25LOOSE;
			translate([0,0, gearDwheelcenter+gearT + outerwallD +plateT]) 
			mirror([0,0,1]) bolt(11, boltD, boltsink);
		}


	}

	
	module wheel_(addR=0, bearingdims=BEARINGDIMSWHEEL){
		threadD = pitchDwheel - 2*GEARMODUL - 3 + 2*addR;
		threadH = gearDwheelcenter+gearT+TIGHTSP;
		
		dtip = addR==0 ? threadD-1. : threadD;
		echo("ThreadD = ", threadD);

		difference(){
		union(){
		wheel_disk(diskT, wheelR, r0);
		cylinder(h=gearDwheelcenter, d=pitchDwheel-3*GEARMODUL);
		translate([0,0,threadH/2]) thread(threadH, threadD, 
						   dtip1=dtip, 
						   dtip2=dtip, 
						   pitch=2, aligner="dontshow", 
						   handness=threadhandness);
		}
		cylinder(h=1000, d=bearingdims[1]+2*bearingoutRsp, center=true);
		}
	}
	
	module axle_(key="axleout", bearingdims=BEARINGDIMSWHEEL){
		
		L = diskT/2+ gearDwheelcenter + gearT;
		D = bearingdims[0] - bearinginRsp*4; //1.5*TIGHTSP;

		boltD = BOLT25LOOSE;
		tightboltD = BOLT25TIGHT;

		if (key=="bolts"){ 
			translate([0,0,-diskT/2-plateT-innerwallD]) bolt(11, boltD, boltsink);
			translate([0,0,-diskT/2 + L + plateT+ outerwallD]) mirror([0,0,1]) bolt(11, boltD, boltsink);	
		}
		else if (key=="axleout"){
			translate([0,0,-diskT/2 ]) 
			
			difference(){
				union(){
				cylinder(h=L, d=bearingAxleD);
				translate([0,0,-innerwallD]) cylinder(h=innerwallD, d=bearingAxleD+2.);
				}
				cylinder(h=1000, d=tightboltD, center=true);
			}

		}
		else if (key=="cover"){
			translate([0,0,-diskT/2 + bearingdims[2]]) 
			difference(){
			cylinder(h=L-2*bearingdims[2], d=bearingdims[0] + 2.);
			cylinder(h=3*(L-2*bearingdims[2]), d=bearingdims[0] + .2, center=true);
			}
		}
		else if (key=="spacerout"){
			translate([0,0,L-diskT/2]) cylinder(h=outerwallD, d=bearingAxleD+2.);
		}
		else if (key=="axlein"){
			//L = innerwallD + bearingdims[2];
			translate([0,0,-diskT/2-innerwallD])
			difference(){
			cylinder(h=innerwallD, d=bearingAxleD+2.);
			cylinder(h=1000, d=boltD, center=true);
			}
		}

		
		
		
	}
	
	
	//translate([4,0,0])axle_();
	//axle_("axlein");
	//axle_("spacerout");
	module motor_(key, L=Lmount){
		translate([0,0,Hgears - motorDtogears]) rotate([0,0,90])
		pololu_motor(key=key, Lmount=L, firewallT=firewallT); //, sp=.5);
	}

	
	module side_out_(key){
		
		wallT = 2;
		Zlow = shiftZ + gearDwheelcenter + outerwallD + gearT - DsidewalltoLeg;
		////translate([0,0,plateT]){
		////	plate(plateDmotor, plateDwheel, Daxles, H=Zlow-plateT, wt=wallT);
		////	translate([0,0,-2]) plate(plateDmotor, plateDwheel, Daxles, H=Zlow-plateT+2, wt=wallT/2, sw=wallT/2);
		////}
		// axles:
		
		module plate_w_axles_(){
			hpole = Zlow - plateT;
			module pole_(){difference(){cylinder(h=hpole, d=BOLT3LOOSE+3);cylinder(h=hpole, d=BOLT3TIGHT);}}

			// plate
			translate([0,0,DsidewalltoLeg])
			translate([0, 0, Zlow]){
			plate(plateDmotor, plateDwheel, Daxles, H=plateT);
			
			

			translate([attpolex, attpoley, -hpole]) pole_();
			translate([attpolex, -attpoley, -hpole]) pole_();
			}

			// axles
			translate([0,0, shiftZ]) {
			translate([middlegearX, 0, 0])gear_gear_("spacer");
			translate([Daxles, 0, 0]) axle_("spacerout");
			}
		}
		
		module shell_(sp){
			fittingH = 1+sp;
			fittingWT = 1+2*sp;
			difference(){
				translate([0,0, DsidewalltoLeg + plateT]){
				plate(plateDmotor, plateDwheel, Daxles, H=Zlow-plateT, wt=wallT);
				translate([0,0,-fittingH]) plate(plateDmotor, plateDwheel, Daxles, H=Zlow-plateT-fittingH, sw=wallT-fittingWT+sp, wt=fittingWT);	
				}

				//wheel_disk(diskT, wheelR, r0, key="cut");
				hull(){
				translate([Daxles, 0, shiftZ]) wheel_disk(diskT, wheelR, r0, key="cut");
				translate([Daxles, 0, -100]) wheel_disk(diskT, wheelR, r0, key="cut");
				}
			}


		}
		
		module cutters_(){
		// Cutters:
			//motor_("cutbearing");
			translate([middlegearX, 0, shiftZ])gear_gear_("bolt");
			translate([Daxles, 0, shiftZ]) axle_("bolts");
			translate([0,0,shiftZ]) gear_motor_("bearing");
			//cylinder(h=10000, d=SERVOBEARINGDIMS[1]+2*TIGHTSP);
		}

		if (key=="out"){
			difference(){
			plate_w_axles_();
			cutters_();
			}
			shell_(sp=0);
		}
		else if (key=="cut"){
			shell_(sp=.1); // TIGHTSP);
		}
	}
	module side_in_(){
		difference(){
			union(){
				translate([0,0,DsidewalltoLeg]) plate(plateDmotor, plateDwheel, Daxles, H=plateT);
				translate([0,0,1]) rotate([0,0,phimiddle]) body(bodyH, bodyW, bodyT, key="wheelaxle");
			}
			// mountp oles:
			translate([0,0,DsidewalltoLeg]){
			translate([Daxles, 0, 0]) bolt(10, BOLT25LOOSE, boltsink);
			translate([attpolex, attpoley, 0]) bolt(10, BOLT3LOOSE, .5);
			translate([attpolex, -attpoley, 0]) bolt(10, BOLT3LOOSE, .5);
			}
			motor_("cutmount", L=Lmount);
			motor_("cutbearing", L=Lmount);
			side_out_("cut");
		}
		
		//motor_("cutmount");
		phimiddle = 25;
	}

	module plate_(D1, D2, D){
		plate(D1, D2, D=D, H=plateT);
	}
	

	//side_out_("out");
	
	diskT = 3;
	r0 = 3/2;
	wheelR = (41.3/2 + 2*r0) + 1; // 22;
	echo(2*wheelR);
	gearT = 4.5;

	outerwallD = 1.5; //*wheelSp;
	innerwallD = 1; //wheelSp;

	ntoothwheel = 20;
	ntoothmotor=17;
	ntoothgear=17;
	pitchDmotor = pitchD(ntoothmotor, GEARMODUL);
	pitchDgear = pitchD(ntoothgear, GEARMODUL);
	pitchDwheel = pitchD(ntoothwheel, GEARMODUL);
	gearSp = .1;

	Daxles = (pitchDwheel + pitchDmotor)/2 + pitchDgear + 2*gearSp;
	
	plateDmotor = WHEELBEARINGDIMS[1]; // PLate diam at motor: #pitchDmotor + 6;
	plateDwheel = 2*wheelR - 2*r0; // PLate diam at wheel

	//translate([0, 0, shiftZ]) wheel_disk(diskT, wheelR, r0, key="cut");

	DsidewalltoLeg = 2.0;
	plateT = 3;
	firewallT = 2.5;

	attpolex = 8.5;
	attpoley = 11.0;

	shiftZ = diskT/2+plateT+innerwallD+DsidewalltoLeg;
	middlegearX = (pitchDmotor+pitchDgear)/2 + gearSp;
	
	gearDwheelcenter = r0 +  2*wheelSp + 3.7;
	Hgears = shiftZ + gearDwheelcenter; 
	motorDtogears=firewallT + .75; //2*wheelSp;
	Lmount = Hgears  - motorDtogears - DsidewalltoLeg; //  - plateT + 1;
	echo(Lmount, Hgears);
	

	pipeL = 10+SERVOHORNT;
	k = legside == "left" ? 0 : 1; 
	mirror([0,0,k])
	if (key=="sidein"){side_in_();}
	else if (key=="sideout"){side_out_("out");}
	else if (key=="gears"){
		gear_gear_();
		// TODO bearing axle!
		translate([0,0, 10]) gear_motor_();
		translate([0,0, 25]) gear_wheel_();
	}
	else if (key=="axles"){
		//translate([0,0, 0]) axle_("axlein");
		translate([0,0, 0]) axle_("axleout");
		translate([0,0, 20]) axle_("cover");
		translate([0,0, 30]) gear_gear_("axle");
	}
	else if (key=="bodygears"){
		body(bodyH, bodyW, bodyT, key="wheelaxleparts");
	}
	else if (key=="motormount"){motor_("mount");}
	else if (key=="wheel"){
		wheel_();

		//translate([0,0, 10]) gear_wheel_();
		//translate([0,0, 40]) axle_("cover");
	}
	else if (key=="tyre"){
		wheel_();
		wheel_disk(diskT, wheelR, r0, key="tyre");
	}
	else if (key=="mockup"){
		translate([0, 0, shiftZ]){	
			gear_motor_();
			gear_motor_("bearing");
			translate([middlegearX, 0, 0]) {
			gear_gear_("gear");
			gear_gear_("axle");
			gear_gear_("spacer");
			}
			translate([Daxles, 0 ,0]){
			wheel_();
			gear_wheel_();	
			axle_();
			axle_("spacerout");
			axle_("axleout");
			axle_("cover");
			wheel_disk(diskT, wheelR, r0, key="tyre");
		}
		}
		motor_("motor");
		motor_("mount");
	}	

}

legside="left";
//wheel(key="mockup", legside=legside);
//wheel(key="sidein", legside=legside);
//wheel(key="motormount", legside=legside);
//wheel(key="gears", legside=legside);
//wheel(key="axles", legside=legside);
//wheel(key="tyre", legside=legside);
//cylinder(h=2, d=41.3 + 6);

//wheel(key="wheel", legside=legside);
//wheel(key="bodygears", legside=legside);
wheel(key="sideout", legside=legside);
