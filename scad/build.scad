use <body.scad>;
use <head.scad>;
include <dims.scad>;

body(bodyH, bodyW, bodyT, key="mockup");

theta = 60;
phi = 40;
translate([0,0, bodyH + neckL]) 
rotate([0,0,phi])
rotate([theta, 0,0]) 
translate([0,0,headL/2]) head(headW, headL, headT, create="mockup");
