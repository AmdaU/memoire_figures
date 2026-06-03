include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);


picture old = currentpicture;

pair vec = (60, 0);
// hex 1
int tensor_count = 0;
int hex_count = 0;

srand(14);

Leg connect_leg = makeLeg("L", dir=(1,0), dim=8, labelStrength=2, align=(-1,3));
int connect_first_idx = 1;
int connect_second_idx = 6;
Leg[] phys_legs = new Leg[] {};


pen[] colors = new pen[] {primary, secondary, tertiary};

//generate a list of 5 random numbers between 0 and 2
pen[] color_list = new pen[20];
for (int i = 0; i < 20; i+=1) {
	color_list[i] = colors[round(2*unitrand())];
}



int dim_of_virtual_leg(int Tensor_idx) {
	if (Tensor_idx < 5) {
		return round(-abs(Tensor_idx - 0.5)) + 5;
	} else {
		return round(-abs(Tensor_idx - 5.5)) + 5;
	}
}


Tensor[] hex_tensors(int hex_rot, pair center, int n = 5) {
	pair pos = center + rotate(60*(hex_rot))*vec;
	pair dir;
	Leg[] v_legs = new Leg[] {};
	Tensor[] hex_1 = new Tensor[] {};
	for (int i = 0; i < n; i+=1) {
		// add virtual legs
		Leg[] legs = new Leg[] {};
		if (i < 4) {
			v_legs.push(makeLeg("v_" + string(i) + "_" + string(hex_count), dir=rotate(60*(i + hex_rot+2))*vec, dim=dim_of_virtual_leg(tensor_count)));
			legs.push(v_legs[i]);
		} 
		if (i > 0) {
			legs.push(dag(v_legs[i-1]));
		}

		// add physical legs
		legs.push(makeLeg("i_" + string(tensor_count), dir=(0,1), labelStrength=0));
		if (tensor_count == connect_first_idx) {
			legs.push(connect_leg);
		}
		if (tensor_count == connect_second_idx) {
			legs.push(dag(connect_leg));
		}
		Tensor T = makeTensor("$T_" + string(tensor_count) + "$", pos, legs, color_list[tensor_count], "circle");
		tensor_count += 1;
		pos += rotate(60*(i + hex_rot+2))*vec;
		hex_1.push(T);
	}
	hex_count += 1;
	return hex_1;
}

Tensor[] hex_1 = hex_tensors(-1, (0,0));
Tensor[] hex_2 = hex_tensors(2, 3*vec + (0, 30), 5);

Tensor[] all_tensors = concat(hex_1, hex_2);

TensorNetwork net = makeTensorNetwork(all_tensors);


picture full_net_pic;
currentpicture = full_net_pic;
draw(net);


picture contracted_net_pic;
currentpicture = contracted_net_pic;
Tensor T1 = contract("$T_1'$", makeTensorNetwork(hex_1), color=color_list[connect_first_idx], shape="square");
Tensor T2 = contract("$T_6'$", makeTensorNetwork(hex_2), color=color_list[connect_second_idx], shape="square");
TensorNetwork contracted_net = makeTensorNetwork(new Tensor[] {T1, T2});
draw(contracted_net);

currentpicture = old;


real gap_arrow = 25;
real arrow_length = 50;

picture [] pics = new picture[] {full_net_pic, contracted_net_pic};
real total_offset = 0;
for (int i = 0; i < pics.length; i+=1) {
  attach(pics[i].fit(), (total_offset,0));
  if (i < pics.length - 1) {
  	pair a = (total_offset+ max(pics[i]).x +gap_arrow, 0);
	pair b = a + (arrow_length,0);
    draw(a--b, defaultLegColor + linewidth(1.5), arrow=Arrows(TeXHead, size=1mm));
    total_offset += -min(pics[i+1]).x;
  }
  total_offset += max(pics[i]).x + 2*gap_arrow + arrow_length;
}
// shipoutWithMargin(2*lw + 2*gap);