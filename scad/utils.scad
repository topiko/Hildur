include <standards.scad>;

function pitchD(ntooth, modul) = ntooth*modul;
function gearD(ntooth, modul) = ntooth*modul + 2*modul;
module bolt(h, d, sink, baseL=5, key="csunk"){
   	
	// Expand the bolt sink hole by this amount: 
	sinkExpFac = 1.1;
	
	// Gray bolts
    	color("Gray")
    	translate([0,0,sink])
    	union(){
		// bolt thread
		translate([0,0,d/2]) cylinder(h=h, r=d/2);
		// bolt base
		if (key=="csunk"){cylinder(h=d/2, r1=d*sinkExpFac, r2=d/2*sinkExpFac);}
		else if (key=="flat"){cylinder(h=d/2 - .2, r=d*sinkExpFac);}
		
		translate([0,0,-baseL - sink]) cylinder(h=baseL + sink, r=d*sinkExpFac);
    	}
}


