include <standards.scad>;

module bolt(h, d, sink, baseL=5){
   	
	// Expand the bolt sink hole by this amount: 
	sinkExpFac = 1.1;
	
	// Gray bolts
    	color("Gray")
    	translate([0,0,sink])
    	union(){
	// bolt thread
    	translate([0,0,d/2]) cylinder(h=h, r=d/2);
	// bolt base
    	cylinder(h=d/2, r1=d*sinkExpFac, r2=d/2*sinkExpFac);
    	translate([0,0,-baseL - sink]) cylinder(h=baseL + sink, r=d*sinkExpFac);
    	}
}


