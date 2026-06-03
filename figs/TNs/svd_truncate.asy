include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

picture old = currentpicture;
externalLegLength = 20;

int default_dim = 6;

legscale = 4;

Leg i = makeLeg("i", dim=default_dim);
Leg i1 = makeLeg("i_1", (0, 1), side=-1, dim=default_dim);
Leg i2 = makeLeg("i_2", (0, 1), dim=default_dim);
Leg virt1 = makeLeg("virt1", (1,0), allowBezier=false, labelStrength=0, dim=default_dim);
Leg virt2 = makeLeg("virt2", (1,0), allowBezier=false, labelStrength=0, dim=default_dim);
Leg virt3 = makeLeg("virt3", (1,0), allowBezier=false, labelStrength=0, dim=2);

Tensor vector = makeTensor("$v$", (0,0), new Leg[] {i}, primary, "triangle");
Tensor vector_split = makeTensor("$v$", (0,0), new Leg[] {i1, i2}, primary, "circle");
Tensor U = makeTensor("$U$", (0,0), new Leg[] {i1, virt1}, primary, "square");
Tensor S = makeTensor("$S$", (45,0), new Leg[] {virt1, virt2}, tertiary, "diamond");
Tensor Vdag = makeTensor("$V^\dagger$", (90,0), new Leg[] {i2, virt2}, primary, "square");
Tensor Up = makeTensor("$U$", (0,0), new Leg[] {i1, virt3}, primary, "square");
Tensor Vdagp = makeTensor("$V^\dagger$", (45,0), new Leg[] {i2, virt3}, primary, "square");

TensorNetwork vector_net = makeTensorNetwork(new Tensor[] {vector});
TensorNetwork vector_split_net = makeTensorNetwork(new Tensor[] {vector_split});
TensorNetwork svd_net = makeTensorNetwork(new Tensor[] {U, S, Vdag});
TensorNetwork MPS_net = makeTensorNetwork(new Tensor[] {Up, Vdagp});

picture old = currentpicture;

picture vector_pic;
currentpicture = vector_pic;
draw(vector_net);
shipoutWithMargin(2*lw + 2*gap, background);

picture vector_split_pic;
currentpicture = vector_split_pic;
draw(vector_split_net);
shipoutWithMargin(2*lw + 2*gap, background);

picture svd_pic;
currentpicture = svd_pic;
draw(svd_net);
shipoutWithMargin(2*lw + 2*gap, background);

picture svd_truncate_pic;
currentpicture = svd_truncate_pic;
draw(svd_net);
real S_off = 5;
real UV_off = 7;
real S_length = 20;
real UV_length = 30;
real thickness = 2;
// strikethrough the S matrix
draw((S.pos + (S_off,-S_length/2))--(S.pos + (S_off, S_length/2)), secondary + linewidth(thickness));
draw((S.pos + (-S_length/2, -S_off))--(S.pos + (S_length/2, -S_off)), secondary + linewidth(thickness));
// strike through the Vdag matrix
draw((Vdag.pos + (UV_off,-UV_length/2))--(Vdag.pos + (UV_off, UV_length/2)), secondary + linewidth(thickness));
shipoutWithMargin(2*lw + 2*gap, background);
// strike through the U matrix
draw((U.pos + (-UV_length/2, -UV_off))--(U.pos + (UV_length/2, -UV_off)), secondary + linewidth(1.5));

picture MPS_pic;
currentpicture = MPS_pic;
draw(MPS_net);
shipoutWithMargin(2*lw + 2*gap, background);

currentpicture = old;


//picture[] pics = new picture[] {vector_pic, vector_split_pic, svd_pic, svd_truncate_pic, MPS_pic};
picture[] pics = new picture[] {svd_pic, svd_truncate_pic, MPS_pic};

currentpicture = old;

real gap_arrow = 7;
real arrow_length = 25;

pair arrow_vector = (arrow_length, 0);
real total_offset = 0;
for (int i = 0; i < pics.length; i+=1) {
  attach(pics[i].fit(), (total_offset,0));
  if (i < pics.length - 1) {
  	pair a = (total_offset+ max(pics[i]).x +gap_arrow, 0);
	pair b = a + arrow_vector;
    draw(a--b, defaultLegColor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));
    if (i == pics.length - 3) {
        // place a approx sign above the arrow
        label("$\approx$", a + arrow_vector/2 + (-2, 7));
    }
    total_offset += -min(pics[i+1]).x;
  }
  total_offset += max(pics[i]).x + 2*gap_arrow + arrow_length;
}
shipoutWithMargin(2*lw + 2*gap, background);