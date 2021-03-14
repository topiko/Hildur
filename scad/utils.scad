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


module thread(h, d, phi=0, threadH=THREADH, pitch=THREADPITCH, aligner="show", dtip1=0, dtip2=0, handness="right"){

	handmltp = handness == "right" ? -1 : 1;
	phi = -phi*handmltp;
	twistphi = handmltp*h/pitch*360;
	dtip1 = dtip1==0 ? d*4/5 : dtip1; // top
	dtip2 = dtip2==0 ? d*4/5 : dtip2; // bottom

	module thread_base(){
		difference(){
		rotate([0,0,twistphi/2])
		linear_extrude(height=h, twist=twistphi, center=true, slices=round(h/.15)) 
		translate([threadH/2,0]) 
		circle(d/2-threadH/2);
		if (htip(dtip1)>0){translate([0,0,h/2]) tipcutter(dtip1);}
		if (htip(dtip2)>0){translate([0,0,-h/2]) mirror([0,0,1]) tipcutter(dtip2);}
		}

	}
	
	tiptheta = 60;
	function htip(dtip) = (d - dtip)/2*tan(tiptheta);

	module tipcutter(dtip){
		htip_ = htip(dtip);
		translate([0,0,-htip_])
		difference(){
			cylinder(h=2*htip_, d=2*d);
			cylinder(h=htip_, d1=d, d2=dtip);
		}
	}
	
	rotate([0,0,phi]){
		if (aligner=="dontshow"){
			thread_base();
		}
		else if (aligner=="show"){	
			thread_base();
			translate([50,0,0])cube([100, 1, 1], center=true);
		}
		else if (aligner=="onlyaligner"){
			translate([50,0,0])cube([100, 1, 1], center=true);
		}
	
	}

}

