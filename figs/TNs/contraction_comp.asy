
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);


picture old = currentpicture;

int[] dims = new int[] {2, 8, 2, 2, 8, 8};


Leg[] legs;
for (int i = 0; i < 6; i+=1) {
  legs.push(makeLeg("i_" + string(i), labelStrength=0, allowBezier=false, dim=dims[i]));
}

legs[5].dir = (1,0);
// legs[0].dir = (1,0);
// legs[2].dir = (1,0);

Tensor T_1= makeTensor("$T_1$", (0,0), new Leg[] {legs[0], legs[2], legs[3]}, primary, "circle");
Tensor T_2 = makeTensor("$T_2$", (-50,-50), new Leg[] {legs[0], legs[1]}, primary, "circle");
Tensor T_3 = makeTensor("$T_3$", (-50,50), new Leg[] {legs[1], legs[2]}, primary, "circle");
Tensor T_4 = makeTensor("$T_4$", (30,40), new Leg[] {legs[3], legs[4], legs[5]}, primary, "circle");
Tensor T_5 = makeTensor("$T_5$", (30,90), new Leg[] {legs[4]}, primary, "circle");


picture step_0_pic;
currentpicture = step_0_pic;
TensorNetwork net = makeTensorNetwork(new Tensor[] {T_1, T_2, T_3, T_4, T_5});
draw(net);


picture step_1_non_optimal;
currentpicture = step_1_non_optimal;

Tensor T_1_4 = contract("", makeTensorNetwork(new Tensor[] {T_1, T_4}), color=primary, shape="circle");
TensorNetwork net_1_4 = makeTensorNetwork(new Tensor[] {T_1_4, T_2, T_3, T_5});
draw(net_1_4);

picture step_2_non_optimal;
currentpicture = step_2_non_optimal;

Tensor T_1_4_5 = contract("", makeTensorNetwork(new Tensor[] {T_1_4, T_5}), color=primary, shape="circle");
TensorNetwork net_1_4_5 = makeTensorNetwork(new Tensor[] {T_1_4_5, T_2, T_3});
draw(net_1_4_5);


picture step_3_non_optimal;
currentpicture = step_3_non_optimal;

Tensor T_1_2_4_5 = contract("", makeTensorNetwork(new Tensor[] {T_1_4_5, T_2}), color=primary, shape="circle");
TensorNetwork net_1_2_4_5 = makeTensorNetwork(new Tensor[] {T_1_2_4_5, T_3});
draw(net_1_2_4_5);

picture step_4_non_optimal;
currentpicture = step_4_non_optimal;

Tensor T_1_2_3_4_5 = contract("", makeTensorNetwork(new Tensor[] {T_1_2_4_5, T_3}), color=primary, shape="circle");
TensorNetwork net_1_2_3_4_5 = makeTensorNetwork(new Tensor[] {T_1_2_3_4_5});
draw(net_1_2_3_4_5);


picture step_1_optimal;
currentpicture = step_1_optimal;
//contract 4 and 5 first
Tensor T_4_5 = contract("", makeTensorNetwork(new Tensor[] {T_4, T_5}), color=primary, shape="circle");
TensorNetwork net_4_5 = makeTensorNetwork(new Tensor[] {T_4_5, T_1, T_2, T_3});
draw(net_4_5);

picture step_2_optimal;
currentpicture = step_2_optimal;
//contract 2 and 3 next
Tensor T_2_3 = contract("", makeTensorNetwork(new Tensor[] {T_2, T_3}), color=primary, shape="circle");
TensorNetwork net_2_3 = makeTensorNetwork(new Tensor[] {T_2_3, T_4_5, T_1});
draw(net_2_3);

picture step_3_optimal;
currentpicture = step_3_optimal;
//contract 2_3 and 1
Tensor T_1_2_3 = contract("", makeTensorNetwork(new Tensor[] {T_2_3, T_1}), color=primary, shape="circle");
TensorNetwork net_1_2_3 = makeTensorNetwork(new Tensor[] {T_1_2_3, T_4_5});
draw(net_1_2_3);

picture step_4_optimal;
currentpicture = step_4_optimal;
//contract 1_2_3 and 4_5
Tensor T_1_2_3_4_5 = contract("", makeTensorNetwork(new Tensor[] {T_1_2_3, T_4_5}), color=primary, shape="circle");
TensorNetwork net_1_2_3_4_5 = makeTensorNetwork(new Tensor[] {T_1_2_3_4_5});
draw(net_1_2_3_4_5);

currentpicture = old;




real gap_arrow = 15;
real arrow_length = 45;
real offset_y = 100;

//attach picture of step_0_pic to the left of the pictures
attach(step_0_pic.fit(), (-80,-30));
real initial_total_offset = max(step_0_pic).x + 2*gap_arrow + arrow_length;
real total_offset;

// diagonal arrows pointing up right and down right
pair arrow_vector = arrow_length*dir(30);
pair a = (0, 60);
pair b = a + arrow_vector;
draw(a--b, defaultLegColor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));
pair arrow_vector = arrow_length*dir(-30);
pair c = (0,-60);
pair d = c + arrow_vector;
draw(c--d, defaultLegColor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));

total_offset = initial_total_offset;
picture [] pics = new picture[] {step_1_optimal, step_2_optimal, step_3_optimal, step_4_optimal};
for (int i = 0; i < pics.length; i+=1) {
  attach(pics[i].fit(), (total_offset, offset_y));
  if (i < pics.length - 1) {
  	pair a = (total_offset+ max(pics[i]).x +gap_arrow, offset_y + 30);
	pair b = a + (arrow_length,0);
    draw(a--b, defaultLegColor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));
    total_offset += -min(pics[i+1]).x;
  }
  total_offset += max(pics[i]).x + 2*gap_arrow + arrow_length;
}



picture [] pics = new picture[] {step_1_non_optimal, step_2_non_optimal, step_3_non_optimal, step_4_non_optimal};
total_offset = initial_total_offset;
for (int i = 0; i < pics.length; i+=1) {
  attach(pics[i].fit(), (total_offset, -offset_y));
  if (i < pics.length - 1) {
  	pair a = (total_offset+ max(pics[i]).x +gap_arrow, -offset_y + 30);
	pair b = a + (arrow_length,0);
    draw(a--b, defaultLegColor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));
    total_offset += -min(pics[i+1]).x;
  }
  total_offset += max(pics[i]).x + 2*gap_arrow + arrow_length;
}
shipoutWithMargin(2*lw + 2*gap, background);