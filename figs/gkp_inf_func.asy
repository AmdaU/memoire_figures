import graph;
include "figs/AutoColors.asy.tmp";
defaultpen(fontsize(12pt) + textcolor);

real l = 50;
int n = 3;
real line_height = 50;
pen state0_color = primary;
pen state1_color = secondary;
pen line_width = linewidth(2pt);

pen axis_pen = linewidth(1pt) + textcolor;


real y_offset = 1.5;
// draw the state 0 lines and ticks
for (int i = -n; i <= n; ++i){
	if (i != 0){
		draw((i*l, y_offset)-- (i*l, line_height), line_width + state0_color);
		xtick("$" + string(i) + "l$", i*l);
	}
}

// draw the state 1 lines and ticks
for (int i = -n+1; i <= n; ++i){
		draw(((i-0.5)*l, y_offset)-- ((i-0.5)*l, line_height), line_width + state1_color);
}

label("$\dots$", (-(n+0.5)*l, line_height/2), fontsize(12pt) + textcolor);
label("$\dots$", ((n+0.5)*l, line_height/2), fontsize(12pt) + textcolor);


draw((0,y_offset)--(0,line_height), line_width+state0_color,
     L=Label("$|\bar 0\rangle$", position=MidPoint, align=E, fontsize(12pt) + textcolor));
draw((0.5*l,y_offset)--(0.5*l,y_offset), line_width+state1_color,
     L=Label("$|\bar 1\rangle$", position=MidPoint, align=E, fontsize(12pt) + textcolor));
xtick("0", 0);

xaxis(xmin=-(n+0.75)*l, xmax=(n+0.75)*l, p=axis_pen,  Arrows(5));
labelx("$x$", 10*S, fontsize(12pt) + textcolor);
yaxis(Label("$\psi(x)$", fontsize(12pt) + textcolor), XEquals(0), axis_pen, EndArrow(5), ymin=0, ymax=line_height*1.5, autorotate=false);

attach(legend(2, nullpen), (point(S).x - 3/2*l,truepoint(S).y*1.4));

shipout(bbox(0.1cm, 0.1cm, nullpen, Fill(background)));
