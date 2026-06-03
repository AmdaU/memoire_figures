include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

int ij_dim = 10;
picture old = currentpicture;

Leg i = makeLeg("i", (0, 1), dim=ij_dim, side=-1);
Leg i_p = makeLeg("i'", (0, 1), dim=ij_dim, side=-1);
Leg j = makeLeg("j", (0, 1), dim=ij_dim);
Leg j_p = makeLeg("j'", (0, 1), dim=ij_dim);
Leg q = makeLeg("q", (0, 1), dim=2);
Leg q_p = makeLeg("q'", (0, 1), dim=2);
Leg q_p_p = makeLeg("q''", (0, 1), dim=2);

real r = 40;
real v_dist = 50;
real total_y = 0;


Tensor ket = makeTensor("0", (0,total_y), new Leg[] {q}, primary, "triangle");
total_y += v_dist;
Tensor CNOT1 = makeTensor("${\rm CNOT}$", (-r/2, total_y), new Leg[] {dag(i), dag(q), i_p, q_p}, secondary, "rect", ratio=0.5, r=r);
total_y += 2*v_dist;
Tensor CNOT2 = makeTensor("${\rm CNOT}$", (r/2, total_y), new Leg[] {dag(q_p), dag(j), q_p_p, j_p}, secondary, "rect", ratio=0.5, r=r);
total_y += v_dist;
Tensor bra = makeTensor("$m$", (0,total_y), new Leg[] {dag(q_p_p)}, primary, "triangle");


Tensor CNOT1_prime = makeTensor("${\rm CNOT}_0$", (-r/2, CNOT1.pos.y), new Leg[] {dag(i), i_p, q_p}, secondary, "rect", ratio=0.5, r=r);
Tensor CNOT2_prime = makeTensor("${\rm CNOT}^m$", (r/2, CNOT2.pos.y), new Leg[] {dag(q_p), dag(j), j_p}, secondary, "rect", ratio=0.5, r=r);


TensorNetwork net_full = makeTensorNetwork(new Tensor[] {CNOT1, CNOT2, ket, bra});
TensorNetwork net_absorbed = makeTensorNetwork(new Tensor[] {CNOT1_prime, CNOT2_prime});

picture full_pic;
currentpicture = full_pic;
draw(net_full);

picture absorbed_pic;
currentpicture = absorbed_pic;
draw(net_absorbed);

picture absorbed_pic_2;
currentpicture = absorbed_pic_2;
// change the direction of the q_p index so that is points to the right
q_p.dir = (1,0);
net_absorbed.tensors[1].legs[0] = dag(q_p);

net_absorbed.tensors[0].ratio = 0.8;
net_absorbed.tensors[0].r = r/(2*0.8);

net_absorbed.tensors[1].ratio = 0.8;
net_absorbed.tensors[1].r = r/(2*0.8);


draw(net_absorbed);

picture side_by_side_pic;
currentpicture = side_by_side_pic;

net_absorbed.tensors[0].pos = (-r, total_y/2);
net_absorbed.tensors[1].pos = (r, total_y/2);


draw(net_absorbed);

currentpicture = old;

real gap_arrow = 15;
real arrow_length = 45;

picture[] pics = new picture[] {full_pic, absorbed_pic, absorbed_pic_2, side_by_side_pic};
// real[] pic_right_edges = [max(full_pic).x, max(absorbed_pic).x, max(side_by_side_pic).x];
real total_offset = 0;
for (int i = 0; i < pics.length; i+=1) {
  attach(pics[i].fit(), (total_offset,0));
  if (i < pics.length - 1) {
  	pair a = (total_offset+ max(pics[i]).x +gap_arrow, total_y/2);
	pair b = a + (arrow_length,0);
    draw(a--b, defaultLegColor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));
    total_offset += -min(pics[i+1]).x;
  }
  total_offset += max(pics[i]).x + 2*gap_arrow + arrow_length;
}
shipoutWithMargin(2*lw + 2*gap, background);