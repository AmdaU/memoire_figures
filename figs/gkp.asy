import settings;
pdfviewer="zathura";
htmlviewer="google-chrome";
// outformat="svg";
display="display";
animate="animate";
gs="gs";

import graph;
import geometry;
import math;
include "figs/AutoColors.asy.tmp";



size(10cm, 10cm);

real pt_s = 0.2;
int grid_l = 7; 
int state = 1;
real l = sqrt(pi);
real delta_like = 100;
pen font_color = RGB(0,0,0);
pen bg_color = background;
// pen red_color = RGB(220,50,50);
pen red_color = mainred;
pen blue_color = mainblue;
//currentpicture.background = bg_color;
bool draw_axis = false;
// currentpicture.background = lightblue;

// main ----------------------------------------------------------------------
for (int i=-floor(grid_l / 2); i<=floor(grid_l / 2); ++i){	
 for (int j=-grid_l + 1; j<grid_l; ++j){
	 filldraw(circle((i * l, j * l/2), pt_s), red_color, linewidth(0pt)+red_color);
 }
}

if (state == 1) {

for (int i=-floor(grid_l / 2); i<=floor(grid_l / 2); i+=2){	
 for (int j=-grid_l; j<grid_l; j+=2){
	 filldraw(circle((i * l, j * l/2), pt_s+0.01), blue_color, linewidth(0pt)+blue_color);
 }
}

} else {
for (int i=-floor(grid_l / 2) -1; i<=floor(grid_l / 2); i+=2){	
 for (int j=-grid_l; j<grid_l; j+=2){
	 filldraw(circle((i * l, j * l/2), pt_s), blue_color, linewidth(0pt)+blue_color);
 }
}
}

// make envelope -------------------------------------------------------------

real rad = (grid_l+1) * l/sqrt(2);
unitsize(1cm);
int n = 100; // number of layers
for(int i=0; i<n; ++i) {
  real r = i/(n-1.0); // normalized radius
  real opa = exp(-delta_like/rad*r*r); // Gaussian function
  pen color = bg_color+opacity(1-opa)+linewidth((rad/(n-1) + 0.1) *cm);
  draw(scale(r*rad)*unitcircle, color);
}


// make text ----------------------------------------------------------------
if (draw_axis) {
	defaultpen(font_color);
	if (state == 0){
	for (int i=-floor(grid_l / 2);i<=floor(grid_l / 2); ++i){	
	label(string(i) + "$\sqrt{\pi}$", (- (floor(grid_l/2)+1)*l, i*l), fontsize(18pt));
	}
	}

	for (int i=-floor(grid_l / 2);i<=floor(grid_l / 2); ++i){	
	label(string(i) + "$\sqrt{\pi}$", (i*l, - (floor(grid_l/2)+0.5)*l), fontsize(18pt));
	}

}

//label ("$|" + string(state) + "\rangle$", (0, (grid_l+0.5)/2 * l), fontsize(20pt));

path boundary = box(((grid_l)*l, (grid_l+2)*l/2), (-(grid_l-1)*l,-(grid_l+1)*l/2)); // the boundary
clip(boundary);

shipout(bbox(2mm, background, Fill));

