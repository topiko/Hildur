use <gears/gears.scad>;

module kst_servo(cut=false, hornR=7, hornT=7){
	W = 23;
	H = 26.5;
	T = 12;
	
	sp = cut ? .1 : 0;

	module frame(){
		cube([W+sp, H+sp, T+sp]);
	}
	
	module attach(){
		attW = 4.5 + sp;
		attT = 1.2 + sp;
		W_ = W + 2*attW;
		translate([0,20,0])
		rotate([90,0,0])
		translate([W_/2-attW, T/2, 0])
		difference(){
		translate([0,0, -attT/2]) cube([W_, T, attT], center=true);
		if (!cut){
		for (i=[-1,1]){ for (j=[-1,1]){ 
			translate([i*(W/2+2), j*3.5, -.1])cylinder(h=2*attT, r=2.2/2);
		}
		}
		}
		}
	}
	
	module horn(){
		translate([6, H, T/2]) rotate([-90,0,0]) 
		{
		cylinder(h=hornT, r=hornR);
		cylinder(h=12, r=4, center=true);
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
		cylinder(h=10, r=6/2);
		translate([0,0,10]) sphere(r=6/2);
		}
	}
	
	color("Silver")	
	rotate([90,0,0])
	translate([-6, -H, -T/2])
	if (cut){ 
		translate([-sp/2, -sp/2, -sp/2]) servo();}
	else {servo();}
		
}


module servo_gear(modul, ntooth, gearT, helix_angle=45){
	// Gear for servo:
	boreD = 5 - .1;
	servoaxleH = 4;
	translate([0, 0, gearT])
	herringbone_gear(modul, ntooth, gearT, 
			 boreD, 
			 pressure_angle=20, 
			 helix_angle=helix_angle, 
			 optimized=false);

	translate([0,0,servoaxleH]) 
	difference(){
	cylinder(h=gearT-servoaxleH - 1, r=boreD/2);
	cylinder(h=gearT-servoaxleH - 1, r=3/2);
	}
	

}



kst_servo();


