use <utils.scad>;
include <standards.scad>;

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



