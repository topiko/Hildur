$fn = 150;
difference(){
	cube([10,20,20]);
	translate([0,5,5]) cube([20, 20,10]);
	translate([0,10,0]) cube([20, 20,15]);
	translate([5, 10, 5]) rotate([-90,0,0]) cylinder(h=20, r=12);
}
