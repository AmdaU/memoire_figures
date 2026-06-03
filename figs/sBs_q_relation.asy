import settings;
pdfviewer="zathura";
outformat="pdf";
tex="pdflatex";

import graph;
import geometry;
import math;
include "figs/AutoColors.asy.tmp";
defaultpen(fontsize(12pt) + textcolor);

usepackage("amssymb");
usepackage("amsmath");
usepackage("physics");
usepackage("graphicx");


size(10cm, 10cm);

unitsize(1cm);

// we include n squares pdf and arrange them in a row, when then add arrows between them

real function_size = 10;
real spacing = 0.6;

// Arrow and label styling
real arrow_scale = 2;  // multiplier for arrow size, line width, and font size

int label_fontsize = 24;  // base font size in points
real line_width = 2;      // base line width in points  
real arrow_size = 4;      // base arrow head size

int n = 4;

int logical_state = 0;

// Labels for each PDF
real pdf_label_offset = function_size/2 + 1;  // vertical offset above PDFs

for (int i = 0; i < n; ++i) {
	real x_pos = i * (function_size * (1 + spacing));
	label(graphic("figs/states/rho_cob_row_" + string(logical_state) + "_" + string(i) + "_0_wigner.pdf", "width=10cm"), (x_pos, 0));
	label("\scalebox{3}{$\ket{0,0," + string(i) + "}$}", (x_pos, pdf_label_offset), NoAlign, textcolor);
}

// Draw arrows between each pair of PDFs
real arrow_gap = 1;  // vertical gap between the two arrows
real arrow_margin = 0.5;  // horizontal margin from PDF edges

pen arrow_pen = linewidth(line_width * arrow_scale) + textcolor;

for (int i = 0; i < n - 1; ++i) {
	real x_start = i * (function_size * (1 + spacing)) + function_size/2 + arrow_margin;
	real x_end = (i + 1) * (function_size * (1 + spacing)) - function_size/2 - arrow_margin;
	real y_center = 0;
	
	// Arrow pointing right (above)
	draw((x_start, y_center + arrow_gap) -- (x_end, y_center + arrow_gap), p=arrow_pen, 
	     arrow=Arrow(TeXHead, size=arrow_size*arrow_scale), 
	     L=Label("$K_{\text{sBs}, q}^\dagger$", position=MidPoint, align=N, fontsize(label_fontsize*arrow_scale) + textcolor));
	
	// Arrow pointing left (below)
	draw((x_end, y_center - arrow_gap) -- (x_start, y_center - arrow_gap), p=arrow_pen, 
	     arrow=Arrow(TeXHead, size=arrow_size*arrow_scale), 
	     L=Label("$K_{\text{sBs}, q}$", position=MidPoint, align=S, fontsize(label_fontsize*arrow_scale) + textcolor));
}

// Add final arrows pointing to continuation dots
{
	real x_start = (n - 1) * (function_size * (1 + spacing)) + function_size/2 + arrow_margin;
	real x_end = n * (function_size * (1 + spacing)) - function_size/2 - arrow_margin;
	real y_center = 0;
	
	// Arrow pointing right (above)
	draw((x_start, y_center + arrow_gap) -- (x_end, y_center + arrow_gap), p=arrow_pen, 
	     arrow=Arrow(TeXHead, size=arrow_size*arrow_scale), 
	     L=Label("$K_{\text{sBs}, q}^\dagger$", position=MidPoint, align=N, fontsize(label_fontsize*arrow_scale) + textcolor));
	
	// Arrow pointing left (below)
	draw((x_end, y_center - arrow_gap) -- (x_start, y_center - arrow_gap), p=arrow_pen, 
	     arrow=Arrow(TeXHead, size=arrow_size*arrow_scale), 
	     L=Label("$K_{\text{sBs}, q}$", position=MidPoint, align=S, fontsize(label_fontsize*arrow_scale) + textcolor));
	
	// Add dotsb in place of n+1th figure
	real dots_x_pos = n * (function_size * (1 + spacing)) - function_size/3;
	label("\scalebox{5}{$\dotsb$}", (dots_x_pos, 0), NoAlign, textcolor);
}

shipout(bbox(5mm, 5mm, nullpen, Fill(background)));