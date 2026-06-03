import settings;
outformat = "pdf";
htmlviewer="/usr/bin/chromium-browser";
//import graph3 -----------------------------------------------------------------------------
import graph;
include "figs/AutoColors.asy.tmp";

real img_size = 2000;
size(img_size);
srand(2);

// parameters (background / textcolor from AutoColors.asy.tmp)
int num_graphs = 50;
int N = 1000;
real r = 0.015;
pen accent = primary;
pen accent2 = secondary;
pen mix_pen(pen p1, pen p2, real ratio){
	return p1 * ratio + p2 * (1-ratio);
}

pen arc_pen = linewidth(img_size * 0.01) + textcolor;
pen axis_pen = linewidth(img_size * 0.01) + textcolor;
pen box_pen = linewidth(img_size * 0.005) + textcolor;
pen transparent = nullpen;
real fontsize = 30;

//draw background


real[] ys;
real[] xs;

for (int i=0; i<N; ++i){
	ys.push(unitrand());
	xs.push(unitrand());
}

// function to get the color of the dot based on the position
int n_inside = 0;
int n_outside = 0;
pen get_color(pair p){
	if (p.x < r || p.y < r || p.x > 1-r || p.y > 1-r){
		return transparent;
	}
	if (1-r < (p.x^2 + p.y^2) && (p.x^2 + p.y^2) < 1+r){
		return transparent;
	}
	if (p.x^2 + p.y^2 < 1){
		++n_inside;
		return accent;
	} else {
		++n_outside;
		return accent2;
	}
}


for (int i=0; i<N; ++i){
	fill(circle((xs[i],ys[i]), r), get_color((xs[i],ys[i])));
}
// draw arc of circle from the x to the y axis 
path arc = arc((0,0), 1, 0, 90);
draw(arc, arc_pen);

// xtick("0", 0, p=fontsize(fontsize));
// xtick("1", 1, p=fontsize(fontsize));
xaxis(xmin=0, xmax=1, p=axis_pen);
// ytick("0", 0, p=fontsize(fontsize));
// ytick("1", 1, p=fontsize(fontsize));
yaxis(ymin=0, ymax=1, p=axis_pen);
// labelx("$x$");

draw((0,1) -- (1,1), box_pen);
draw((1,0) -- (1,1), box_pen);

// label("$\pi$ = " + string(4 * n_inside / (n_inside + n_outside)), (0.5,0.5));
shipout(bbox(2mm, background, Fill));
