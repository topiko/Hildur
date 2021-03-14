use <body.scad>;
use <head.scad>;
include <dims.scad>;
color("Gray")
body(bodyH, bodyW, bodyT, key="mockup");

theta = -40;
phi = 20;
color("Gray")
translate([neckX,-25, bodyH + neckL]) 
rotate([0,0,phi])
rotate([theta, 0,0]) 
translate([-neckX,-0,headL/2]) head(headW, headL, headT, create="mockup");
