use <utils.scad>;
include <standards.scad>;

module rpizero(key, H=5){
	
	dims = [65,30,2];
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
cylinder(h=H+dims[2]+1, r=2.8/2);
}
			}
			else if (key=="bolts"){
				mirror([0,0,1]) bolt(5,BOLT3TIGHT, -dims[2]);
			}
		}
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
}
