include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

int i_dim = 5;
picture old = currentpicture;
string orientation_string = "horizontal";
real r = 20;
real rect_ratio = 0.5;
real triangle_r = 15;
real v_dist = 50;


externalLegLength = 20;

pair orientation = (1, 0);
if (orientation_string == "horizontal") {
  orientation = (1, 0);
} else if (orientation_string == "vertical") {
  orientation = (0, 1);
}

Leg i_0 = makeLeg("i", orientation, dim=i_dim);
Leg i_2 = makeLeg("i_1", orientation, dim=i_dim);
Leg i_4 = makeLeg("i_2", orientation, dim=i_dim);
Leg i_5 = makeLeg("i'", orientation, dim=i_dim);
Leg q_0 = makeLeg("q_0", orientation, dim=2);
Leg q_1 = makeLeg("q_1", orientation, dim=2);
Leg q_2 = makeLeg("q_2", orientation, dim=2);
Leg q_3 = makeLeg("q_3", orientation, dim=2);
Leg q_4 = makeLeg("q_4", orientation, dim=2);
Leg q_5 = makeLeg("q_5", orientation, dim=2);

real rect_r;
if (orientation_string == "vertical") {
  rect_r = 2*r;
  rect_ratio = 0.5;
} else if (orientation_string == "horizontal") {
  rect_r = 1.1*r;
  rect_ratio = 2/1.1;
}
real total_y = 0;

real rot_angle = degrees(orientation) - 90;


Tensor ket = makeTensor("$+$", rotate(rot_angle)*(-r,total_y), new Leg[] {q_0}, primary, "triangle", r=triangle_r);
total_y += v_dist/1.3;

Tensor CD_0 = makeTensor("${\rm CD}(s)$", rotate(rot_angle)*(0, total_y), new Leg[] {dag(q_0), dag(i_0), q_1, i_2}, secondary, "rect", ratio=rect_ratio, r=rect_r);
total_y += v_dist;

Tensor R_0 = makeTensor("${\rm R}_x(\frac{\pi}{2})$", rotate(rot_angle)*(-r, total_y), new Leg[] {dag(q_1), q_2}, tertiary, "square", r=r);
total_y += v_dist;

Tensor CD_1 = makeTensor("${\rm CD}(B)$", rotate(rot_angle)*(0, total_y), new Leg[] {dag(q_2), dag(i_2), q_3, i_4}, secondary, "rect", ratio=rect_ratio, r=rect_r);
total_y += v_dist;

Tensor R_1 = makeTensor("${\rm R}_x^\dagger(\frac{\pi}{2})$", rotate(rot_angle)*(-r, total_y), new Leg[] {dag(q_3), q_4}, tertiary, "square", r=r);
total_y += v_dist;

Tensor CD_2 = makeTensor("${\rm CD}(s)$", rotate(rot_angle)*(0, total_y), new Leg[] {dag(q_4), dag(i_4), q_5, i_5}, secondary, "rect", ratio=rect_ratio, r=rect_r);
total_y += v_dist/1.3;

Tensor bra = makeTensor("$m$", rotate(rot_angle)*(-r,total_y), new Leg[] {dag(q_5)}, primary, "triangle", r=triangle_r);


TensorNetwork net_full = makeTensorNetwork(new Tensor[] {ket, CD_0, R_0, CD_1, R_1, CD_2, bra});

picture full_pic;
currentpicture = full_pic;
draw(net_full);

picture contracted_ket_and_bra_pic;
currentpicture = contracted_ket_and_bra_pic;
Tensor CD_0_p = contract("${\rm CD}(s)^+$", makeTensorNetwork(new Tensor[] {CD_0, ket}), color=secondary, shape="rect", ratio=rect_ratio, r=rect_r, pos=CD_0.pos);
Tensor CD_2_p = contract("${\rm CD}(s)^m$", makeTensorNetwork(new Tensor[] {CD_2, bra}), color=secondary, shape="rect", ratio=rect_ratio, r=rect_r, pos=CD_2.pos);
TensorNetwork net_contracted_ket_and_bra = makeTensorNetwork(new Tensor[] {CD_0_p, R_0, CD_1, R_1, CD_2_p});
draw(net_contracted_ket_and_bra);


picture contracted_pic;
currentpicture = contracted_pic;

Tensor sBs_m = makeTensor("${\rm sBs}^m$", rotate(rot_angle)*(0, total_y), new Leg[] {dag(i_0), i_5}, secondary, "square", r=r);
TensorNetwork net_contracted = makeTensorNetwork(new Tensor[] {sBs_m});
draw(net_contracted);



currentpicture = old;

real gap_arrow = 10;
real arrow_length = 25;

picture[] pics = new picture[] {full_pic, contracted_ket_and_bra_pic, contracted_pic};
// real[] pic_right_edges = [max(full_pic).x, max(absorbed_pic).x, max(side_by_side_pic).x];
real total_offset = 0;
for (int i = 0; i < pics.length; i+=1) {
  attach(pics[i].fit(), (total_offset,0));
  if (i < pics.length - 1) {
  	pair a = (total_offset+ max(pics[i]).x +gap_arrow, 0);
	pair b = a + (arrow_length,0);
    draw(a--b, defaultLegColor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));
    total_offset += -min(pics[i+1]).x;
  }
  total_offset += max(pics[i]).x + 2*gap_arrow + arrow_length;
}
shipoutWithMargin(2*lw + 2*gap, background);