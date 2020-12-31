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
		for (p=mountpos){
		translate(p) translate([0,0,H]) mirror([0,0, 1]) bolt(boltH, boltD, -boltD/2);
		}
	}
	
	translate([-dims[0]/2, -dims[1]/2, 0])
	if (key=="mockup"){
		echo("mckup");
		poles();
		translate([0,0,H]) cube(dims);
	}
	else if (key=="bolts"){bolts();}
	else if (key=="poles"){poles();}
}


module micarray(H=5, key="mockup", boltH=0){
	
	dims = [65, 65, 2];
	mountpos = [[3, 8], [62, 8], [3, 57], [62, 57]];
	boltD = BOLT3TIGHT;
	boltH= boltH==0 ? H + 1: boltH; //  + 1.5;
	H = H;
	color("DarkSlateGray")	
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
		
		for (phi=[0:90:270]){
			rotate([0,0,phi])
			translate([-dims[0]/2+0.7, dims[1]/2 - 4.0 - 2.0, -mich + H]) cube([4, 6, mich]);
		}
	}
	
	if (key=="micsleds"){
		ledring();
		micring();
	}
	
}

module servoctrl(H=5, key="mockup", boltH=0, boltD=BOLT25TIGHT){
	dims = [63, 25.5, 2];
	mountpos = [[3, 3], [60, 3], [3, 22], [60, 22]];
	boltH= boltH==0 ? H + 1: boltH; //  + 1.5;
	H = H;
	color("DarkSlateGray")	
	generalel(dims, mountpos, boltD=boltD, H=H, key=key, boltH=boltH);

}

module battery(key="3S"){
	if (key=="3S"){cube([30,27, 55], center=true);}
	else if (key=="2S"){cube([35,18, 67], center=true);}
}


micarray(H = 5, key="mockup");
micarray(H=5, key="micsleds");
micarray(H=5, key="bolts");
