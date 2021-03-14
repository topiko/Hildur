include <standards.scad>;
use <utils.scad>;

servoctrldims = [30,20,10];
servoctrlmntpos = [[0,1], [20, 10]];

module generalel(dims, mountpos, boltD=BOLT3TIGHT, H=2, key="mockup", boltH=0){
	
	
	module poles(){
		for (p=mountpos){
			translate(p) cylinder(h=H, r=boltD);
		}
	}

	module bolts(){
		boltH = boltH == 0 ? H : boltH;
		
		color("Gray")	
		for (p=mountpos){
			translate(p) translate([0,0,H]) mirror([0,0, 1]) bolt(boltH, boltD, -boltD/2);
		}
	}
	
	translate([-dims[0]/2, -dims[1]/2, 0])
	if (key=="mockup"){
		echo("mckup");
		poles();
		color("Navy")
		translate([0,0,H]) cube(dims);
	}
	else if (key=="bolts"){bolts();}
	else if (key=="poles"){poles();}
}


module micarray(H=5, key="mockup", boltH=0){
	
	dims = [65, 65, 2];
	mountpos = [[3.5, 8], [61.5, 8], [3.5, 57], [61.5, 57]];
	boltD = BOLT25TIGHT;
	boltH= boltH==0 ? H + 1: boltH; //  + 1.5;
	H = H;

	generalel(dims, mountpos, boltD=boltD, H=H, key=key, boltH=boltH);
	
	module ledring(){
		ringh = boltH;
		translate([0,0,H-ringh])
		difference(){
			cylinder(h=ringh, r=62/2);
			cylinder(h=ringh, r=62/2-5);
		}
	}
	
	module micring(){
		mich = H + 15;
		
		for (phi=[90:90:360]){
			rotate([0,0,phi])
			translate([dims[0]/2 - 2 - 1., dims[1]/2 - 3, -mich/2 + H]) 
			cube([4+1, 3+1, mich], center=true);
		}
	}
	
	if (key=="micsleds"){
		ledring();
		micring();
	}
	
}

module servoctrl(H=5, key="mockup", boltH=0, boltD=BOLT25TIGHT){
	dims = [63, 25.5, 2];
	mountpos = [[3.5, 3], [59.5, 3], [3.5, 22], [59.5, 22]];
	//boltH= boltH==0 ? H : boltH; //  + 1.5;
	color("DarkSlateGray")	
	generalel(dims, mountpos, boltD=boltD, H=H, key=key, boltH=boltH);

}

module protoboard(H=5, key="mockup", boltH=0, boltD=BOLT25TIGHT){

	dims = [80, 20.5, 2];
	mountpos = [[2.5, 2.5], [77.5, 2.5], [2.5, 18], [77.5, 18]];
	
	//boltH = boltH==0 ? H: boltH; //  + 1.5;
	
	color("DarkSlateGray")	
	generalel(dims, mountpos, boltD=boltD, H=H, key=key, boltH=boltH);
}



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


module rpizero(key, H=5, T=2){
	
	dims = [65,30,T];
	mount_holes = [[3.5, 3.5], [dims[0]-3.5, 3.5],
		       [3.5, dims[1]-3.5], [dims[0]-3.5, dims[1]-3.5]];
	module board(){
		translate([0,0,dims[2]/2]) cube(dims, center=true);
	}
	
	module mountpoles(H=H, key="poles"){
		translate([-dims[0]/2, -dims[1]/2, 0])
		for (p=mount_holes){
			translate(p)
			if (key=="poles"){
				translate([0,0, -H]) {
				cylinder(h=H, r=BOLT3LOOSE);
				//cylinder(h=H+dims[2]+1, r1=2.75/2, r2=2.6/2);
}
			}
			else if (key=="bolts"){
				mirror([0,0,1]) bolt(H - .2, BOLT3TIGHT, -BOLT3TIGHT/2);
			}
		}
	}
	
	module usbcharge(){
		dy = 2.;
		translate([dims[0]/2, -dims[1]/2+11, -1.5])
		hull(){
		for (j=[-1,1]) translate([0, j*dy, 0]) rotate([0,90,0]) cylinder(h=20, r=3.5);
		}
	}
	
	module pwrswitch(){
		translate([dims[0]/2 - 20.5, -dims[1]/2 - 2, -H-5]) cube([5, 2, 10]);
	}
	
	translate([0,0,H])
	if (key=="boardpoles"){
		board();
		mountpoles();
	}
	else if (key=="poles"){
		mountpoles();
	}
	else if (key=="bolts"){
		mountpoles(key="bolts");
	}
	else if (key=="cuts"){
		usbcharge();
		pwrswitch();
	}
}


module battery(key="3S"){
	if (key=="3S"){cube([30,27, 55], center=true);}
	else if (key=="2S"){cube([35,18, 67], center=true);}
}


micarray(H = 5, key="mockup");
micarray(H=5, key="micsleds");
micarray(H=5, key="bolts");
