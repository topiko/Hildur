include <standards.scad>;
use <utils.scad>;

module camera(cut, H=30){
	holeD = 30;
	cameraW = 38;
	cameraR = 32/2;
	mountH = H;
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
	else {
		difference(){
		mount();
		camandbolts();}
	}
}


