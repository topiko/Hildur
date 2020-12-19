use <servo_mount.scad>;
use <jetson.scad>;
use <utils.scad>;
include <standards.scad>;

function get_r(R, T, x, sc) = sqrt(pow(R, 2)-pow((T/2-x)/sc, 2));

module head_shell(R, T, shellT, botT, scY, top){
	
	module shell_(){
	scZ = T/(2*R);
	scX = 1;

	scZ_in = (T-2*shellT)/(2*R);
	scY_in = (scY*2*R - shellT*2)/(2*R);
	scX_in = (scX*2*R - shellT*2)/(2*R);
	translate([0,0, T/2 - botT])
	difference(){
		scale([scX, scY, scZ]) sphere(R);	
		scale([scX_in, scY_in, scZ_in]) sphere(R);	
	}
	}

	
	shift = top ? 2*R : -2*R;
	color("DarkSlateGray")
	intersection(){
		translate([0,0,shift]) cube(4*R, center=true);
		shell_();
	}
	
}


module head_close_bolts(R, T, botT, scY, Dr, boltD){
	
	dphi = 45;
	phimax = 360-dphi;
	sc = T/(2*R);
	for (phi=[0:dphi:phimax]){
		r = get_r(R, T, botT, sc) - Dr;
		x = r*cos(phi);
		y = r*sin(phi)*scY;
		translate([x, y, 0]) bolt(15, boltD, -boltD/2, baseL=20); //cylinder(h=10, r=boltD/2);
	}
}

module neck_joint(platealpha, cut){
	
	addR = 2;
	plateT = BEARINGT + 1;
	R = BEARINGR + 2;
	//plateaplha = 20;
	H = 40;
	W = 2*H*tan(platealpha) + 2*R;
	axleR = 5/2;
	module plate_(){
		difference(){
		// Base plate 
		hull(){
		cylinder(h=plateT, r=R, center=true);
		translate([-R, -1 + H, -plateT/2]) cube([W, 1, plateT]);
		//linear_extrude(height=plateT, center=true) polygon(points=[[-W/2, ]]);
		}
		// Bearing mount
		translate([0,0,-1])cylinder(h=BEARINGT+1, r=BEARINGR+RSPACING, center=true);
		// Axle
		cylinder(h=plateT*2, r=axleR, center=true);
		}
	}
	
	platesDist = 20;
	//rotate([0,0, rotalpha])
	if (cut){
		rotate([90,0,0]) cylinder(h=2*H, r=platesDist/2, center=true);	
	}
	else {
		DZ = (platesDist + plateT)/2;
		translate([0,0,-DZ]) plate_();
		translate([0,0,DZ]) mirror([0,0,1])plate_();
	}

}


module camera(cut){
	holeD = 30;
	cameraW = 38;
	cameraR = 32/2;
	mountH = 46;
	mountR = 3;

	mountHoles= [for (i=[-1, 1]) for (j=[-1,1]) [i*holeD/2, j*holeD/2, 0]];
	
	module mount(){
		for (p=mountHoles){
			translate(p) cylinder(h=mountH, r=mountR);
		}
	}

	module camandbolts(){

		// Camera	
		color("Black") cylinder(h=35, r=cameraR);
		for (p=mountHoles){
			translate(p) bolt(6, BOLT3TIGHT, -BOLT3TIGHT/2);
		}
	}

	if (cut){ camandbolts();}
	else {mount();}
}





module backhead(R, T, shellT, botT, scY){
	module boltrim(){
		rimT = 10;
		sc = T/(2*R);
		rimR = get_r(R, T, botT, sc);
		intersection(){
		scale([1,scY, 1])
		translate([0,0,-rimT])
		difference(){
		cylinder(h=rimT, r=5*rimR);
		translate([0,0,-1]) cylinder(h=2*rimT+1, r=rimR-boltrimW-BOLT3LOOSE);
		}	
		head_shell(R, T, R, botT, scY, false);
		}
	}
	module shifted_neck(){
		cutR = get_r(R, T, botT, T/(2*R)) - BEARINGR - 2;
		translate([0,-cutR, -BEARINGR-10]) 

		rotate([90, 0, 0]) 
		rotate([0, 90, 0]) 
		neck_joint(3, false);
	}

	module neck(){
		difference(){	
		shifted_neck();
		head_shell(R, T, R, botT, scY, true);
		head_shell(R, T, R, botT, scY, false);
		}
	}
	module backheadwadds(){	
		head_shell(R, T, shellT, botT, scY, false);
		boltrim();
		servo_mount("base");
		//neck();
	}
	
	module servo_mount(key){
		
		servoRotX = -13;
		servoShiftX = 0;
		servoShiftY = -47;
		servoShiftZ = -botT + 19.5;
	
		module servo_base(){
			intersection(){
			head_shell(R, T, 10, botT, scY, false);
			translate([servoShiftX, servoShiftY, servoShiftZ])
			rotate([servoRotX, 0, 0]){
			rotate([-90,0,90]) servo_mount_w_axle(false, servoNTooth=14, 
						     axleNTooth=26, 
						     key="box");
			}
			}
		}
		module servo(key){
			translate([servoShiftX, servoShiftY, servoShiftZ])
			rotate([servoRotX, 0, 0]){
			/*rotate([-90,0,90]) servo_mount_w_axle(false, servoNTooth=14, 
						     axleNTooth=26, 
						     key="top");*/
			rotate([-90,0,90]) servo_mount_w_axle(false, servoNTooth=14, 
						     axleNTooth=26, 
						     key=key);
}
		}
		
		if (key=="base"){servo_base();}
		else {servo(key);}
	}	
	module backheadwcuts(){
		difference(){
		backheadwadds();
		// closing bolts
		translate([0,0,-.6]) head_close_bolts(R, T, botT, scY, boltrimW - BOLT3LOOSE, BOLT3LOOSE);
		// servo cuts:
		servo_mount("bolts");
		servo_mount("cut");
		// Face cuts
		face(R, T, shellT, botT, scY, key="cut"); 
		// Fo cbles to escape:
		dx = 30;
		dy = -40;
		cableR = 10;
		rotX = 50;
		for (i=[-1,1]){
			translate([i*dx, dy, 0]) rotate([-rotX, 0,0]) cylinder(h=2*R, r=cableR, center=true);
		}
		}
	}
	color(FACECOLOR)
	backheadwcuts();
	//servo_mount("cut");
}

module face(R, T, shellT, botT, scY, key="build"){
	
	
	module jetsonattach(){

		intersection(){
		translate(jetsonPos)jetson("mount");
		head_shell(R, T, R, botT, scY, true);
		}
	}	
	

	module jetsonmock(heatsinkH=30){
		translate(jetsonPos) jetson("jetson", heatsinkH);
	} 
	module boltrim(){
		rimT = 3;
		sc = T/(2*R);
		rimR = get_r(R, T, botT, sc);
		scY_in = (scY*rimR - boltrimW)/rimR;
		scX_in = (rimR - boltrimW)/rimR;
		intersection(){
		difference(){
		scale([1,scY, 1]) cylinder(h=rimT, r=5*rimR);
		translate([0,0,-1]) scale([scX_in, scY_in, 1]) cylinder(h=2*rimT+1, r=rimR);
		}	
		head_shell(R, T, R, botT, scY, true);
		}
	}
	
	module cameraeye(cut){
		trans = [-R + eyefracpos[0]*2*R, 
			 -R*scY + eyefracpos[1]*2*R*scY, 
			 0 + eyefracpos[2]];
		if (cut){
			translate(trans) camera(cut);
		}
		else {
			intersection(){
			head_shell(R, T, R, botT, scY, true);
			translate(trans) camera(cut);
			}
		}
	}	
	
	module ledeye(){
		trans = [R- eyefracpos[0]*2*R,
			 -R*scY + eyefracpos[1]*2*R*scY, 
			 0];
		translate(trans) cylinder(h=4*T, r=LEDR);
	}
	
	module ledmouth(){
		dx = 9;
		mouthrot = -12;
		row1 = [-2*dx, -dx, 0, dx, 2*dx];
		row2 = [-dx, 0, dx];
		LEDR = (3 + .05)/2;	
		trans = [-R + mouthfracpos[0]*2*R,
  			 -R*scY + mouthfracpos[1]*2*R*scY,
  			 0];
		translate(trans){
		rotate([0,0,mouthrot]){
		for (x=row1){translate([x, 0, 0]) cylinder(h=4*T, r=LEDR);}
		for (x=row2){translate([x, -dx, 0]) cylinder(h=4*T, r=LEDR);}
		}
		}
	}
	
	module facewadds(){
		head_shell(R, T, shellT, botT, scY, true);
		cameraeye(false);
		boltrim();
		//neck();
		jetsonattach();
	}
	centerH = T/2 - botT;
	cameraJetsonD=7;
	mouthfracpos = [.46, .22, 0];	
	jetsonPos = [0, 14, centerH+3];
	eyefracpos = [.28, .63, jetsonPos[2]+cameraJetsonD];	
	
	echo("Jetson eye poses Z:");
	echo(jetsonPos[2], eyefracpos[2]);
	echo(jetsonPos[2]);
	module facewcuts(){
		difference(){
		facewadds();
		cameraeye(true);
		ledeye();
		ledmouth();
		head_close_bolts(R, T, botT, scY, boltrimW - BOLT3LOOSE, BOLT3TIGHT);
		}
	}
	
	color(FACECOLOR)
	if (key=="cut"){
		jetsonmock(70);
	}
	else if (key=="build"){
		facewcuts();}
	//jetsonmock();
	//jetsonattach();

}


FACECOLOR = "DarkSlateGray";
R = 75;
T = 77;
shellT = 1.2;
botT = 25;
scY = 1.1;
HCAMERA = 30;
RCAMERA = 10;
WCAMERA = 35;
RSPACING = .10;

echo(T/2 - botT);

BEARINGT = 5;
BEARINGR = 12/2;

BOLT3TIGHT = 2.75;
BOLT3LOOSE = 3.1;

LEDR = 5/2;

boltrimW = 8;



//face(R, T, shellT, botT, scY); //, key="cut"); 
/*difference(){
face(R, T, shellT, botT, scY); 
translate([0,0,-500+T/2-botT]) cube(1000, center=true);
}*/

backhead(R, T, shellT, botT, scY);

bodyR = 1.4*R;
bodyT = 1.5*T;
bodyScY = 1.3;


//echo(bodyScY*bodyR*2);
//neck_joint(10, true);
//translate([0,-R-BEARINGR,BEARINGR+2]) rotate([0, -90, 0]) rotate([0,0, -10]) neck_joint(20, false);
//translate([0, -R -bodyScY*bodyR, 0]) head_shell(bodyR, bodyT, shellT, botT, bodyScY, true);
//jetson_camera_mount(true);
//jetson_camera_mount(false);
//head_close_bolts(R, T, botT, scY, 0); //shellT/2);
//echo(get_r(R, T, botT));
//translate([0,0,-10]) head_shell(R, T, shellT, x, scY, false);
//bolt(10, BOLT3LOOSE, -BOLT3LOOSE/2);


//jetson("mount");
//jetson("jetson");
