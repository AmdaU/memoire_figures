import settings;
pdfviewer="zathura";
htmlviewer="google-chrome";
outformat="pdf";
display="display";
animate="animate";
gs="gs";

usepackage("amsmath");

usepackage("amssymb");

import graph;
import geometry;
import math;
//TN file
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + textcolor);
// draw first matrix
picture old = currentpicture;

picture first_matrix;
currentpicture = first_matrix;
label("$\begin{pmatrix} \begin{matrix} s_{1} & & 0 \\ & \ddots & \\ 0 & & s_{\chi} \end{matrix} & \\ & \begin{matrix} s_{\chi+1} & & 0 \\ & \ddots & \\ 0 & & s_{d} \end{matrix} \end{pmatrix}$", (0,0), fontsize(18pt) + textcolor);
// get the size of the first matrix and write it to variables
pair matMin = min(first_matrix);
pair matMax = max(first_matrix);
real w = matMax.x - matMin.x;
real h = matMax.y - matMin.y;

// pair offset = (0,+h/4);

picture second_matrix;
currentpicture = second_matrix;

label("$\begin{pmatrix} \begin{matrix} s_{1} & & 0 \\ & \ddots & \\ 0 & & s_{\chi} \end{matrix} & \\ & \begin{matrix} \phantom{s_{\chi+1}} & & \phantom{0} \\ & \ooalign{\hfil$\vcenter{\hbox{\mbox{\Huge$\mathbf{0}$}}}$\hfil\cr\hfil$\phantom{\ddots}$\hfil} & \\ \phantom{0} & & \phantom{s_{d}} \end{matrix} \end{pmatrix}$", (0,0), fontsize(18pt) + textcolor);

picture third_matrix;
currentpicture = third_matrix;
label("$\begin{pmatrix} s_{1} & & 0 \\ & \ddots & \\ 0 & & s_{\chi} \end{pmatrix}$", (0,0), fontsize(18pt) + textcolor);
// shipout(bbox(2mm, background, Fill));
currentpicture = old;


picture[] pics = new picture[] {first_matrix, second_matrix, third_matrix};

currentpicture = old;

real gap_arrow = 10;
real arrow_length = 25;
pair arrow_vector = (arrow_length, 0);

real total_offset = 0;
for (int i = 0; i < pics.length; i+=1) {
  if (i == 0) {
	attach(pics[i].fit(), (total_offset,0) + offset);
  } else {
	  attach(pics[i].fit(), (total_offset,0));
  }
  if (i < pics.length - 1) {
  	pair a = (total_offset+ max(pics[i]).x +gap_arrow, 0);
	pair b = a + (arrow_length,0);
    draw(a--b, textcolor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));
    total_offset += -min(pics[i+1]).x;
    if (i == 0) {
        // place a approx sign above the arrow
        label("$\approx$", a + arrow_vector/2 + (-2, 7), fontsize(18pt) + textcolor);
    }
  }
  total_offset += max(pics[i]).x + 2*gap_arrow + arrow_length ;
}
shipoutWithMargin(2*lw + 2*gap, background);
