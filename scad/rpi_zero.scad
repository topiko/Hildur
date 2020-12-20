use <utils.scad>;
include <standards.scad>;

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
				mirror([0,0,1]) bolt(H+dims[2],BOLT3TIGHT, 0);
			}
		}
	}
	
	module usbcharge(){
		dy = 5;
		translate([dims[0]/2, -dims[1]/2+11, -1.5])
		hull(){
		for (j=[-1,1]) translate([0, j*dy, 0]) rotate([0,90,0]) cylinder(h=20, r=3.5);
		}
	}
	
	module pwrswitch(){
		translate([dims[0]/2 - 18, -dims[1]/2 - 2, -H-5]) cube([5, 2, 10]);
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

rpizero("cuts", H=4, T=12);
rpizero("boardpoles", H=4, T=12);
