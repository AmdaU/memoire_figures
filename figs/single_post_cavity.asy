settings.outformat = "png";
settings.render = 16;
import graph3;
import solids;
include "figs/AutoColors.asy.tmp";

size(400);
currentprojection = perspective(12, -12, 10);
currentlight = light(gray(0.55), specular=gray(0.9), (10, -10, 20), (-10, 10, 20));
currentlight.background = background;

// Materials
material aluminum = material(diffusepen=primary, specularpen=white, shininess=0.9);
material copper = material(diffusepen=mainred, specularpen=white, shininess=0.8);
material transparent_casing = material(diffusepen=gray(0.9)+opacity(0.3), specularpen=white, shininess=0.5);

// Dimensions
real R_cav = 2.0;
real H_cav = 6.0;
real r_post = 0.6;
real h_post = 3.5; // Height of straight part of post

// --- Central Post ---
// Cylinder
draw(surface(cylinder((0,0,0), r_post, h_post, axis=Z)), aluminum);
// Rounded Top (Sphere - bottom half hidden)
draw(surface(sphere((0,0,h_post), r_post)), aluminum);

// --- Cavity Floor ---
draw(surface(circle((0,0,0), R_cav)), aluminum);

// --- Outer Shell (Transparent) ---
draw(surface(cylinder((0,0,0), R_cav, H_cav, axis=Z)), transparent_casing);
// Top
draw(shift(0,0,H_cav)*surface(circle((0,0,0), R_cav)), transparent_casing);

// --- Input Port (Coax) ---
real h_port = 3.0;
real r_port_outer = 0.5;
real r_port_inner = 0.15;
real len_port = 1.5;

// Outer conductor of port (cylinder sticking out)
triple port_start = (R_cav, 0, h_port);
draw(surface(cylinder(port_start, r_port_outer, len_port, axis=X)), transparent_casing);

// Inner Conductor (Pin)
real penetration = 0.5;
triple pin_start = (R_cav - penetration, 0, h_port);
draw(surface(cylinder(pin_start, r_port_inner, len_port + penetration, axis=X)), copper);

// Caps for pin
draw(surface(circle(pin_start, r_port_inner, normal=X)), copper);
draw(surface(circle(pin_start+(len_port+penetration,0,0), r_port_inner, normal=X)), copper);
