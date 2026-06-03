include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

//picture old = currentpicture;
externalLegLength = 20;


Leg b1 = makeLeg("b_1");
Leg b2 = makeLeg("b_2");
Leg q = makeLeg("q");

Tensor CD1 = makeTensor("CD_1", (0,0), new Leg[] {b1, q, dag(b1), dag(q)}, primary, "rect");
Tensor CD2 = makeTensor("CD_2", (0,0), new Leg[] {b2, dag(q), dag(b2), dag(dag(q))}, primary, "rect");
Tensor ket0 = makeTensor("1", (0,0), new Leg[] {q}, primary, "circle");
Tensor ket1 = makeTensor("1", (0,0), new Leg[] {q}, primary, "circle");
 
TensorNetwork full = makeTensorNetwork(new Tensor[] {ket0});

draw(full);
// picture old = currentpicture;

// picture vector_pic;
// currentpicture = vector_pic;
// draw(vector_net);
// shipoutWithMargin(2*lw + 2*gap);

// picture vector_split_pic;
// currentpicture = vector_split_pic;
// draw(vector_split_net);
// shipoutWithMargin(2*lw + 2*gap);

// picture svd_pic;
// currentpicture = svd_pic;
// draw(svd_net);
// shipoutWithMargin(2*lw + 2*gap);

// picture MPS_pic;
// currentpicture = MPS_pic;
// draw(MPS_net);
// shipoutWithMargin(2*lw + 2*gap);

// currentpicture = old;


// pair total_offset = (100,0);
// picture[] pics = new picture[] {vector_pic, vector_split_pic, svd_pic, MPS_pic};
// for (int i = 0; i < pics.length; i+=1) {
//   attach(pics[i].fit(), total_offset);
//   if (i < pics.length - 1) {
//   	pair a = total_offset + (max(pics[i]).x, 0);
// 	pair b = total_offset + (max(pics[i]).x,0) + (30,0);
//     draw(a--b, defaultLegColor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));
//   }
// 	total_offset += (max(pics[i]).x, 0);
// 	total_offset += (60, 0);
//}
shipoutWithMargin(2*lw + 2*gap, background);