import settings;
outformat = "pdf";
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

picture old = currentpicture;
externalLegLength = 15;

int len_ends = 2;
int len_center = 4;
real dist = 40;
int dim_edges = 2;
int dim_physical = 15;
legscale = 2;

Leg[] legs_physical_start = new Leg[len_ends];
Leg[] legs_virtual_start = new Leg[len_ends];
Leg[] legs_physical_start_prime = new Leg[len_ends];
Leg[] legs_physical_end = new Leg[len_ends];
Leg[] legs_virtual_end = new Leg[len_ends];
Leg[] legs_physical_end_prime = new Leg[len_ends];
for (int n = 0; n < len_ends; n+=1) {
  legs_physical_start[n] = makeLeg("i'_{" + string(n+1) + "}", (0, 1), dim=dim_physical);
  legs_physical_start_prime[n] = makeLeg("i_{" + string(n+1) + "}", (0, -1), dim=dim_physical, side=-1);
  int dim = dim_edges+n;
  legs_virtual_start[n] = makeLeg("v_" + string(n+1), (-1, 0), allowBezier=false, labelStrength=0, dim=3^dim);
  string end_label = "i_{2n-" + string(len_ends-n-1) + "}";
  if (n == len_ends-1) {
    end_label = "i_{2n}";
  }
  legs_physical_end[n] = makeLeg(end_label + "'", (0, 1), dim=dim_physical);
  legs_physical_end_prime[n] = makeLeg(end_label, (0, -1), dim=dim_physical, side=-1);
  int dim = dim_edges+len_ends-n;
  legs_virtual_end[n] = makeLeg("v_" + end_label, (-1, 0), allowBezier=false, labelStrength=0, dim=3^dim);
}

Tensor[] T_start= new Tensor[len_ends];
Tensor[] T_end = new Tensor[len_ends];

for (int n = 0; n < len_ends; n+=1) {
  Leg[] legs_start;
  Leg[] legs_end;
  legs_start.push(legs_physical_start[n]);
  legs_start.push(legs_physical_start_prime[n]);
  if (n > 0) {
    legs_start.push(legs_virtual_start[n-1]);
  }
  legs_start.push(dag(legs_virtual_start[n]));
  legs_end.push(legs_physical_end[n]);
  legs_end.push(legs_physical_end_prime[n]);
  legs_end.push(legs_virtual_end[n]);
  if (n < len_ends-1) {
    legs_end.push(dag(legs_virtual_end[n+1]));
  }
  T_start[n] = makeTensor("", (n*dist,0), legs_start, secondary, "circle");
  T_end[n] = makeTensor("", ((n)*dist,0), legs_end, secondary, "circle");
}


int dim_center = dim_edges + len_ends + round(len_center/2);
Leg[] legs_physical_center;
Leg[] legs_virtual_center;
Leg[] legs_physical_center_prime;
int start_index = -round(len_center/2)+1;
int end_index = round(len_center/2);
int offset = -start_index;
// label(string(start_index) + " " + string(end_index) + " " + string(offset), (0,0));
for (int n = start_index; n <= end_index; n+=1) {
  string center_label = "i_{n+" + string(n) + "}";
  pen segment_color = textcolor;
  if (n == 0) {
    segment_color = tertiary;
  }
  if (n == 0) {
    center_label = "i_{n}";
  } else if ( n < 0) {
    center_label = "i_{n" + string(n) + "}";
  }
  if (n == start_index) {
    int dim = dim_center-abs(n-1);
    legs_virtual_center.push(makeLeg("v_" + string(n), (-1, 0), allowBezier=false, labelStrength=0, dim=3^dim));
  }
  int dim = dim_center-abs(n);
  legs_physical_center.push(makeLeg(center_label + "'", (0, 1), dim=dim_physical));
  legs_physical_center_prime.push(makeLeg(center_label, (0, -1), dim=dim_physical, side=-1));
  legs_virtual_center.push(makeLeg("v_" + string(n+1), (-1, 0), allowBezier=false, labelStrength=0, dim=3^dim, color=segment_color));
}

Tensor[] T_center = new Tensor[len_center];
for (int n = start_index; n <= end_index; n+=1) {
  Leg[] legs_center;
  legs_center.push(legs_physical_center[n+offset]);
  legs_center.push(legs_physical_center_prime[n+offset]);
  legs_center.push(legs_virtual_center[n+offset]);
  legs_center.push(dag(legs_virtual_center[n+1+offset]));
  T_center[n+offset] = makeTensor("", (n*dist,0), legs_center, secondary, "circle");
}

TensorNetwork net_start = makeTensorNetwork(T_start);
TensorNetwork net_end = makeTensorNetwork(T_end);
TensorNetwork net_center = makeTensorNetwork(T_center);

// draw(net_center);
//draw(net_end);
//draw(net_center);

picture pic_center;
currentpicture = pic_center;
draw(net_center);

picture pic_start;
currentpicture = pic_start;
draw(net_start);

picture pic_end;
currentpicture = pic_end;
draw(net_end);

currentpicture = old;


real total_offset = 0;
real dots_length = 35;
picture[] pics = new picture[] {pic_start, pic_center, pic_end};
for (int i = 0; i < pics.length; i+=1) {
  total_offset += -min(pics[i]).x;
  attach(pics[i].fit(), (total_offset,0));
  total_offset += max(pics[i]).x + dots_length;
  if (i < pics.length - 1) {
    label("$\dots$", (total_offset - dots_length/2, 0), fontsize(12pt) + textcolor);
  }
}

shipoutWithMargin(2*lw + 2*gap, background);