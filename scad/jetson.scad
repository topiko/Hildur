include <standards.scad>;
use <utils.scad>;

module jetson(key, heatsinkH=30){

	jetsonMountHoles = [[4, 17], [90, 17], [4, 75], [90, 75]];
	jetsonCorners = [[0,0], [100, 0], [100,80], [0, 80]];
	jetsonHeatSinkCorners = [[22, 38], [82, 38], [82, 78], [22, 78]];
	jetsonConnectorsCorners = [[15, -1], [86, -1], [86, 22], [15, 22]];

	mountH = 40;
	mountD = 9;
	breadboardT = 2;
	
	module jetson_(){
		translate([0,0,-breadboardT/2]){
		linear_extrude(height=breadboardT) polygon(points=jetsonCorners);	
		// Heatsink:
		linear_extrude(height=heatsinkH) polygon(points=jetsonHeatSinkCorners);
		linear_extrude(height=20) polygon(points=jetsonConnectorsCorners);
		}
	}
	module pole(){
		attachD = 5;
		transitionH = mountD - attachD;
		translate([0,0, breadboardT/2])
		difference(){
		union(){
		translate([0,0,transitionH])cylinder(h=mountH-transitionH, r=mountD/2);
		cylinder(h=transitionH, r1=attachD/2, r2=mountD/2);
		}
		bolt(6, BOLT3TIGHT, -BOLT3TIGHT/2);
		}

	}
	// mount bars:
	module mount(){
		mirror([0,0,1])
		for (p=jetsonMountHoles){
			translate(p) pole();	
	}
	}
	
		
	rotate([0,180,0])
	
	//mirror([0,0,1])
	translate([-jetsonCorners[1][0]/2, -jetsonCorners[2][1]/2, 0])
	if (key=="jetson"){jetson_();}
	else if (key=="mount"){mount();}
	else {jetson_(); mount();};
	
}

jetson("jetson");
