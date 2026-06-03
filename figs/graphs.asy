import settings;
outformat = "pdf";
htmlviewer="/usr/bin/chromium-browser";
import graph3;
include "figs/AutoColors.asy.tmp";

real scale = 10;
size(200*scale);
//darkmode barkground
//size3(200,IgnoreAspect);
//currentprojection=perspective(0,0,10,Y);
//currentprojection = perspective((0,0,100), (0,1,0), (20,0,-10));
currentprojection = perspective((70,0,100), (0,1,0), (0,0,-10));
srand(2);

// parameters
int num_graphs = 50;
real d_graph = 5;
real d_last_plane = 5;
int N = 50;
real noise_amp = 6;
real sin_amp = 10;
real depth = 10;
pen accent = secondary;
pen accent2 = primary;
real plane_opacity = 0.5;
// very light grey
pen mix_pen(pen p1, pen p2, real ratio){
	return p1 * ratio + p2 * (1-ratio);
}
pen plane_color = mix_pen(primary, background, 0.1);
pen curve_color = textcolor + linewidth(0.4*scale);
pen arrow_width = linewidth(0.4*scale);
pen border_width = linewidth(0.4*scale);


currentlight = light(gray(0.45), specular=gray(0.85), (40, 30, 50), (-30, -20, 40));
currentlight.background = background;

real tot_amp = sin_amp + noise_amp;

// Generate N equally spaced points between 0 and 2π
real[] z; // array to store the points
for (int i = 0; i < N; ++i) {
  z.push(2*pi*i/(N-1));
}


real[][] ys;

for (int i=0; i<num_graphs; ++i){
	//make sins with every point of the sinewave shifted randomly
	real[] y;
	for (int j=0; j<N; ++j){
		y.push(sin_amp*sin(z[j]) + noise_amp*unitrand());
	}
	ys.push(y);
}

for (int i=0; i<num_graphs; ++i){

	
	real[] y = ys[i];
	real[] x = 0*z + d_graph*i;
	triple A = (x[0],-tot_amp,0);
	triple B = (x[0],tot_amp,0);
	triple C = (x[0],tot_amp,-depth*2*pi);
	triple D = (x[0],-tot_amp,-depth*2*pi);
	//triple A = (0,0,0), B = (10,0,0), C = (10,10,0), D = (0,10,0);

	// Create a closed guide (polygon) from the points:
	guide3 poly = A--B--C--D--cycle;

	// Convert the guide into a surface:
	surface s = surface(poly);
	draw(poly, opacity(0.5) + accent2+border_width, nolight);
	draw(s, plane_color+opacity(plane_opacity), nolight);
	draw(graph(x,y,-z*depth), curve_color, nolight);

}

for (int i=0; i<9; ++i){
	triple p = ((i+0.5)*d_graph,0,-pi*depth);
	label('$\mathbf{+}$',p, textcolor+fontsize(8));
}


// sum all the graphs
real[] y = 0*z;
for (int i=0; i<num_graphs; ++i){
	y = y + ys[i]/num_graphs;
}
real last_x = d_graph*(num_graphs+5);
draw(graph(last_x+z*0,y,-depth*z), curve_color);

//draw the plane
triple A = (last_x,-tot_amp,0);
triple B = (last_x,tot_amp,0);
triple C = (last_x,tot_amp,-depth*2*pi);
triple D = (last_x,-tot_amp,-depth*2*pi);
//triple A = (0,0,0), B = (10,0,0), C = (10,10,0), D = (0,10,0);

// Create a closed guide (polygon) from the points:
guide3 poly = A--B--C--D--cycle;

// Convert the guide into a surface:
surface s = surface(poly);
draw(s, plane_color+opacity(plane_opacity), nolight);
draw(poly, opacity(0.5) + accent2+border_width, nolight);




//draw arrow
real margin = 5;
triple start = (d_graph*(num_graphs-1) + margin,0,-pi*depth);
triple end = (last_x-margin*1.5,0,-pi*depth);

draw(start--end, accent+arrow_width, Arrow3(7*scale));


real last_x = d_graph*(num_graphs+25);
//draw(graph(last_x+z*0,y,-depth*z), opacity(0));

