import settings;
outformat = "pdf";
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

picture old = currentpicture;

int len_center = 5;
int ortho_index = round(len_center/2)-1;
real dist = 50;
real bra_off_up = 100;
legscale = 6;
externalLegLength = 20;

Leg[] legs_physical_center;
Leg[] legs_virtual_center;
Leg[] legs_physical_bra;
Leg[] legs_virtual_bra;
for (int n = 0; n < len_center; n+=1) {
  if (n == 0) {
    int arr = (0 <= ortho_index) ? -1 : 1;
    legs_virtual_center.push(makeLeg("v_0", (-1, 0), allowBezier=false, labelStrength=0, arrow=arr));
    legs_virtual_bra.push(makeLeg("v'_0", (-1, 0), allowBezier=false, labelStrength=0, arrow=arr));
  }
  legs_physical_center.push(makeLeg("i_" + string(n+1), (0, 1), labelStrength=0));
  int arr = (n+1 <= ortho_index) ? -1 : 1;
  legs_virtual_center.push(makeLeg("v_" + string(n+1), (-1, 0), allowBezier=false, labelStrength=0, arrow=arr));
  legs_physical_bra.push(dag(legs_physical_center[n]));
  legs_virtual_bra.push(makeLeg("v'_" + string(n+1), (-1, 0), allowBezier=false, labelStrength=0, arrow=arr));
}
Leg primed_index = makeLeg(legs_physical_center[ortho_index].label + "'", (0, 1));

Tensor[] T_ket = new Tensor[len_center];
Tensor[] T_bra = new Tensor[len_center];
Tensor[] T_G;
Tensor[] T_D;
Tensor[] T_Lambda;
for (int n = 0; n < len_center; n+=1) {
  string tensor_label = "T_G";
  pen tensor_color = primary;
  if (n == ortho_index) {
    tensor_color = tertiary;
	tensor_label = "\Lambda";
  } else if (n > ortho_index) {
    tensor_color = secondary;
	tensor_label = "T_D";
  }
  Leg[] legs_center;
  legs_center.push(legs_physical_center[n]);
  legs_center.push(legs_virtual_center[n]);
  legs_center.push(dag(legs_virtual_center[n+1]));
  T_ket[n] = makeTensor("$" + tensor_label + "$", (n*dist,0), legs_center, tensor_color, "circle");
  Leg[] legs_bra;
  if (n == ortho_index) {
    legs_bra.push(dag(primed_index));
  } else {
    legs_bra.push(legs_physical_bra[n]);
  }
  legs_bra.push(legs_virtual_bra[n]);
  legs_bra.push(dag(legs_virtual_bra[n+1]));
  T_bra[n] = makeTensor("$" + tensor_label + "^\dagger$", (n*dist,bra_off_up), legs_bra, tensor_color, "circle");
  if (tensor_label == "T_G") {
    T_G.push(T_ket[n]);
    T_G.push(T_bra[n]);
  } else if (tensor_label == "T_D") {
    T_D.push(T_ket[n]);
    T_D.push(T_bra[n]);
  } else if (tensor_label == "\Lambda") {
    T_Lambda.push(T_ket[n]);
    T_Lambda.push(T_bra[n]);
  }
}

Tensor one_site_op = makeTensor("$\hat O$", (ortho_index*dist, bra_off_up/2), new Leg[] {primed_index, dag(legs_physical_center[ortho_index])}, tertiary, "square");

picture pic_ket;
currentpicture = pic_ket;
TensorNetwork net_ket = makeTensorNetwork(T_ket);
draw(net_ket);

label("$\dots$", (-dist,0), fontsize(20));
label("$\dots$", (dist*(len_center),0), fontsize(20));

picture pic_ket_bra;
currentpicture = pic_ket_bra;
Tensor[] ket_bra = concat(T_ket, T_bra);
ket_bra.push(one_site_op);
TensorNetwork net_ket_bra = makeTensorNetwork(ket_bra);
draw(net_ket_bra);

picture T_G_pic;
currentpicture = T_G_pic;
TensorNetwork net_T_G = makeTensorNetwork(T_G);
draw(net_T_G);

label("$\dots$", (-dist,0), fontsize(20));
label("$\dots$", (-dist,bra_off_up), fontsize(20));
// arc cricle
path arc = arc((-dist*1.5,bra_off_up/2), bra_off_up/2, -90, -270);
draw(arc, linewidth(2));

label("$=$", (dist*(ortho_index),bra_off_up/2), fontsize(20));
draw(shift((dist*(3 + ortho_index),0))*arc, linewidth(2));

picture contracted_pic;
currentpicture = contracted_pic;
Tensor identity_left = makeTensor("", (0,bra_off_up/2), new Leg[] {dag(legs_virtual_center[0]), dag(legs_virtual_bra[0])}, primary, "id_v");
Tensor identity_right = makeTensor("", (dist * (len_center-1),bra_off_up/2), new Leg[] {dag(legs_virtual_center[len_center]), legs_virtual_bra[len_center]}, primary, "id_v");
T_G.push(identity_left);
T_D.push(identity_right);
Tensor T_G_contracted = contract("", makeTensorNetwork(T_G), shape="id_v");
Tensor T_D_contracted = contract("", makeTensorNetwork(T_D), shape="id_v");
// make the remaining legs point up and down respectively and allow bezier
T_G_contracted.legs[0].allowBezier = true;
T_G_contracted.legs[0].dir = (0,-1);
T_G_contracted.legs[0].arrow = 0;
T_G_contracted.legs[1].allowBezier = true;
T_G_contracted.legs[1].dir = (0,1);
T_G_contracted.legs[1].arrow = 0;
T_D_contracted.legs[0].allowBezier = true;
T_D_contracted.legs[0].dir = (0,-1);
T_D_contracted.legs[0].arrow = 0;
T_D_contracted.legs[1].allowBezier = true;
T_D_contracted.legs[1].dir = (0,1);
T_D_contracted.legs[1].arrow = 0;
TensorNetwork net_contracted = makeTensorNetwork(concat(new Tensor[] {T_G_contracted, T_D_contracted, one_site_op}, T_Lambda));
draw(net_contracted);


picture T_Lambda_pic;
currentpicture = T_Lambda_pic;
TensorNetwork net_T_Lambda = makeTensorNetwork(T_Lambda);
draw(net_T_Lambda);

currentpicture = old;

real total_offset = 0;
real dots_length = 35;
picture[] pics = new picture[] {pic_ket};

for (int i = 0; i < pics.length; i+=1) {
  total_offset += -min(pics[i]).x;
  attach(pics[i].fit(), (total_offset,0));
  total_offset += max(pics[i]).x + dots_length;
  if (i < pics.length - 1) {
    label("$\dots$", (total_offset - dots_length/2, 0));
  }
}
shipoutWithMargin(2*lw + 2*gap, background);