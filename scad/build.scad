use <body.scad>;
use <head.scad>;
include <dims.scad>;

body(bodyH, bodyW, bodyT, wallT=wallT, key="mockup");

translate([0,12,headL/2 + bodyH + neckL]) head(headW, headL, headT, create="mockup");
