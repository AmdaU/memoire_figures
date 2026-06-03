import settings;
pdfviewer="zathura";
outformat="pdf";

import graph;
import geometry;
import math;
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultpen(fontsize(12pt) + textcolor);

usepackage("amssymb");
usepackage("amsmath");



size(10cm, 10cm);

unitsize(1cm);

real pt_s = 0.15;
int grid_l = 7; 
int state = 1;
real l = sqrt(pi);
real delta_like = 100;
int title_fontsize = 30;
bool draw_axis = true;



picture old = currentpicture;
picture wigner_pic;
currentpicture = wigner_pic;

real l = sqrt(pi);

unitsize(1cm);

// main ----------------------------------------------------------------------

path boundary = box(((grid_l-1)*l, (grid_l+2)*l/2), (-(grid_l-2)*l,-(grid_l+10)*l/2)); // the boundary

real rad = (grid_l+1) * l/sqrt(2);

real envelope_keep(pair p) {
  real r = length(p)/rad;
  return exp(-delta_like/rad*r*r); // keep the state-1 radial profile
}

pen blend_peak_with_background(pen peak, real keep) {
  keep = max(0, min(1, keep));
  return (1 - keep) * background + keep * peak;
}

for (int i=-floor(grid_l / 2); i<=floor(grid_l / 2); ++i){	
 for (int j=-grid_l + 1; j<grid_l; ++j){
	 pair p = (i * l, j * l/2);
	 pen c = blend_peak_with_background(mainred, envelope_keep(p));
	 filldraw(circle(p, pt_s), c, linewidth(0pt)+c);
 }
}

if (state == 0) {

for (int i=-floor(grid_l / 2); i<=floor(grid_l / 2); i+=2){	
 for (int j=-grid_l; j<grid_l; j+=2){
	 pair p = (i * l, j * l/2);
	 pen c = blend_peak_with_background(mainblue, envelope_keep(p));
	 filldraw(circle(p, pt_s+0.01), c, linewidth(0pt)+c);
 }
}

} else {
for (int i=-floor(grid_l / 2) -1; i<=floor(grid_l / 2); i+=2){	
 for (int j=-grid_l; j<grid_l; j+=2){
	 pair p = (i * l, j * l/2);
	 pen c = blend_peak_with_background(mainblue, envelope_keep(p));
	 filldraw(circle(p, pt_s), c, linewidth(0pt)+c);
 }
}
}

// Envelope is now baked directly into point colors (no alpha overlay artifacts).
label(state == 0 ? "$|\bar 0\rangle$" : "$|\bar{1}\rangle$",
      (0, (grid_l+1.8)*l/2),
      fontsize(title_fontsize) + textcolor,
      align=S);


// wavefunction ----------------------------------------------------------------

picture wavefunction_pic;
currentpicture = wavefunction_pic;

real gkp_x(real x, real Delta=0.3) {
	real sum = 0;
	real delta2 = Delta^2;
	real C = cosh(delta2);
	real S = sinh(delta2);
	
	// The exact propagator for e^{-Delta^2 n} (Mehler kernel)
	real prefactor = 1/sqrt(pi*(1-exp(-2*delta2)));
	
	// Sum over grid points
	int N = 10;
	for(int n=-N; n<=N; ++n) {
		real q = (2 * n + state) * l;
		
		real val = -(C*(x^2 + q^2) - 2*x*q)/(2*S);
		sum += exp(val);
	}
	
	return prefactor * sum;
}

real gkp_p(real p, real Delta=0.3) {
	real sum = 0;
	real delta2 = Delta^2;
	real C = cosh(delta2);
	real S = sinh(delta2);
	
	// The exact propagator for e^{-Delta^2 n} (Mehler kernel)
	real prefactor = 1/sqrt(pi*(1-exp(-2*delta2)));
	
	// Sum over grid points
	int N = 10;
	for(int n=-N; n<=N; ++n) {
		real p_grid = (2 * n) * l/2;
		
		real val = -(C*(p^2 + p_grid^2) - 2*p*p_grid)/(2*S);
		sum += exp(val);
	}
	
	return prefactor * sum;
}

unitsize(1cm);
// wavefunction
int n = floor(grid_l/2/2);
real line_height = l;
pen state0_color = secondary;
pen state1_color = primary;
pen line_width = linewidth(4pt);
int fontsize = 18;
real delta_f = 0.2;

pen axis_pen = linewidth(1pt) + textcolor;

// // draw the state 0 lines and ticks
// for (int i = -n; i <= n; ++i){
// 	if (i != 0){
// 		draw((i*l*2, 0)-- (i*l*2, line_height), line_width + state0_color);
// 	}
// }
// plot the wavefunction
// make an array of 100 points between -n*l*2 and n*l*2
real[] x;
int num_points = 1000;
for (int i = 0; i < num_points; ++i){
	x.push(-n*l*2*1.8 + i*(2*n*l*2*1.8)/num_points);
}
real[] y;
for (int i = 0; i < num_points; ++i){
	y.push(gkp_x(x[i], delta_f));
}
draw(graph(x, y), line_width + state0_color);


//label("$\dotsb$", (-(n+0.8)*2*l, line_height*0.72));
//label("$\dotsb$", ((n+0.8)*2*l, line_height*0.72));


//xtick("0", 0);

for (int i=-floor(grid_l / 2);i<=floor(grid_l / 2); ++i){	
	string label_string = string(i);
	if (i == 0){
		label_string = "$0$";
	}
	else{
		label_string = string(i) + "$\sqrt{\pi}$";
	}
label(label_string, (i*l, -0.5), fontsize(fontsize) + textcolor);
}

xaxis(xmin=-(n+1)*2*l, xmax=(n+1)*2*l, p=axis_pen,  Arrows(5));
labelx("$\hat q$",S, fontsize(fontsize*2) + textcolor);
yaxis(Label("$|\psi(x)|^2$", fontsize(fontsize*1.2) + textcolor, align=E), XEquals(-grid_l*l/2), axis_pen, EndArrow(5), ymin=0, ymax=line_height*1.2, autorotate=false);




shipoutWithMargin(2mm, background);

// wavefunction p ----------------------------------------------------------------

pen fully_transparent = background + opacity(0);

picture wavefunction_pic_2;
currentpicture = wavefunction_pic_2;

line_height = line_height*1.2;

unitsize(1cm);
// wavefunction
int n = floor(grid_l/2);

pen axis_pen = linewidth(1pt) + textcolor;

real[] p;
for (int i = 0; i < num_points; ++i){
	p.push(-n*l*1.2 + i*(2*n*l*1.2)/num_points);
}
real[] psi_p;
for (int i = 0; i < num_points; ++i){
	psi_p.push(gkp_p(p[i], delta_f));
}
draw(graph(psi_p, p), line_width + state0_color + fully_transparent);


//label("$\vdots$", (line_height*0.82, (n+0.75)*l), fully_transparent);
//label("$\vdots$", (line_height*0.82, -(n+0.75)*l), fully_transparent);


//xtick("0", 0);

for (int i=-floor(grid_l / 2);i<=floor(grid_l / 2); ++i){	
	string label_string = string(i);
	if (i == 0){
		label_string = "$0$";
	}
	else{
		label_string = string(i) + "$\sqrt{\pi}$";
	}
label(label_string, (-line_height, i*l), fontsize(fontsize) + fully_transparent, align=E);
}


yaxis(ymin=-((n+1/2)+0.75)*l, ymax=((n+1/2)+0.75)*l, p=axis_pen + fully_transparent,  Arrows(5));
labely("$\hat p$",2*W, fontsize(fontsize*2) + fully_transparent);
xaxis(Label("$|\psi(p)|^2$", fontsize(fontsize*1.2) + fully_transparent, align=N), YEquals((grid_l+1/2)*l/2), axis_pen + fully_transparent, EndArrow(5), xmin=0, xmax=line_height*1.2);




// For |\bar 1>, the p profile is identical to |\bar 0>; keep this inset area
// only as a blank placeholder so global figure geometry stays aligned.
//fill(box((line_height*1.6, ((n+1/2)+1.0)*l),
         //(-line_height*1.6, -((n+1/2)+1.0)*l)), bg_color);

shipoutWithMargin(2mm, background);



// attach pictures ----------------------------------------------------------------
currentpicture = old;

attach(wigner_pic.fit(), (0,0));
attach(wavefunction_pic.fit(), (0,-line_height*1.2 - grid_l*l/2));
pair p_inset_center = (-line_height*1.2 - (grid_l+1/2)*l/2, 0);
attach(wavefunction_pic_2.fit(), p_inset_center);
attach(legend(2, nullpen), (point(S).x - 3/2*l,truepoint(S).y*1.4));

clip(boundary);
shipoutWithMargin(2mm, background);