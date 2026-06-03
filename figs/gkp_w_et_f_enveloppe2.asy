import settings;
pdfviewer="zathura";
htmlviewer="google-chrome";
outformat="pdf";
display="display";
animate="animate";
gs="gs";

import graph;
import geometry;
import math;
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";

usepackage("amssymb");
usepackage("amsmath");



size(10cm, 10cm);

unitsize(1cm);

real pt_s = 0.15;
int grid_l = 7; 
int state = 0;
real l = sqrt(pi);
real delta_like = 90;
pen font_color = RGB(0,0,0);
pen bg_color = RGB(223, 218, 209);
bool draw_axis = true;



picture old = currentpicture;
picture wigner_pic;
currentpicture = wigner_pic;

real l = sqrt(pi);

unitsize(1cm);

// main ----------------------------------------------------------------------

path boundary = box(((grid_l)*l, (grid_l+2)*l/2), (-(grid_l-1)*l,-(grid_l+1)*l/2)); // the boundary
clip(boundary);



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
		real q = (2 * n + state) * l/2;
		
		real val = -(C*(p^2 + q^2) - 2*p*q)/(2*S);
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

pen axis_pen = linewidth(1pt);

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


label("$\dotsb$", (-(n+0.5)*2*l, line_height/2));
label("$\dotsb$", ((n+0.5)*2*l, line_height/2));


//xtick("0", 0);

for (int i=-floor(grid_l / 2);i<=floor(grid_l / 2); ++i){	
	string label_string = string(i);
	if (i == 0){
		label_string = "$0$";
	}
	else{
		label_string = string(i) + "$\sqrt{\pi}$";
	}
label(label_string, (i*l, -0.5), fontsize(fontsize));
}

xaxis(xmin=-(n+1)*2*l, xmax=(n+1)*2*l, p=axis_pen,  Arrows(5));
labelx("$\hat x$",S, fontsize(fontsize*2));
yaxis(Label("$|\psi(x)|^2$", fontsize(fontsize*1.2), align=E), XEquals(-grid_l*l/2), axis_pen, EndArrow(5), ymin=0, ymax=line_height*1.2, autorotate=false);




shipoutWithMargin(2mm, background);

// wavefunction p ----------------------------------------------------------------

picture wavefunction_pic_2;
currentpicture = wavefunction_pic_2;

line_height = line_height*1.2;

unitsize(1cm);
// wavefunction
int n = floor(grid_l/2);

pen axis_pen = linewidth(1pt);

real[] p;
for (int i = 0; i < num_points; ++i){
	p.push(-n*l*1.2 + i*(2*n*l*1.2)/num_points);
}
real[] psi_p;
for (int i = 0; i < num_points; ++i){
	psi_p.push(gkp_p(p[i], delta_f));
}
draw(graph(psi_p, p), line_width + state0_color);


label("$\vdots$", (line_height/2, (n+0.5)*l));
label("$\vdots$", (line_height/2, -(n+0.5)*l));


//xtick("0", 0);

for (int i=-floor(grid_l / 2);i<=floor(grid_l / 2); ++i){	
	string label_string = string(i);
	if (i == 0){
		label_string = "$0$";
	}
	else{
		label_string = string(i) + "$\sqrt{\pi}$";
	}
label(label_string, (-line_height, i*l), fontsize(fontsize), align=E);
}


yaxis(ymin=-((n+1/2)+0.75)*l, ymax=((n+1/2)+0.75)*l, p=axis_pen,  Arrows(5));
labely("$\hat p$",2*W, fontsize(fontsize*2));
xaxis(Label("$|\psi(p)|^2$", fontsize(fontsize*1.2), align=N), YEquals((grid_l+1/2)*l/2), axis_pen, EndArrow(5), xmin=0, xmax=line_height*1.2);




shipoutWithMargin(2mm, background);



// attach pictures ----------------------------------------------------------------
currentpicture = old;

attach(wigner_pic.fit(), (0,0));
attach(wavefunction_pic.fit(), (0,-line_height*1.2 - grid_l*l/2));
attach(wavefunction_pic_2.fit(), (-line_height*1.2 - (grid_l+1/2)*l/2, 0));
attach(legend(2, nullpen), (point(S).x - 3/2*l,truepoint(S).y*1.4));