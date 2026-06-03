import settings;
outformat = "pdf";
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

picture old = currentpicture;
externalLegLength = 20;
legscale = 3;

int N = 6;
real dist = 50;
real dist_split = 60;
pen primary_color = primary;
pen logical_color = secondary;
pen gauge_color = tertiary;

// Panel A: Standard MPS with large physical indices
int dim_phys = 50;
int dim_virt = 4;

Leg[] phys = new Leg[N];
Leg[] virt = new Leg[N-1];
string numerical_label(int n, int N) {
  if (n < round(N/2)) {
    return string(n+1);
  } else {
    return "n-" + string(N-n);
  }
}
for (int n = 0; n < N; n+=1) {
  phys[n] = makeLeg("p" + string(n), (0, 1), dim=dim_phys,
                     label="$i_{" + numerical_label(n, N) + "}$");
}
for (int n = 0; n < N-1; n+=1) {
  string label = "";
  int labelStrength = 0;
  if (n == round(N/2)-1) {
    label = "$\cdots$";
    labelStrength = 1;
  }
  virt[n] = makeLeg("v" + string(n), (1, 0), dim=dim_virt, label=label, labelStrength=labelStrength, allowBezier=false, side=-1);
}

Tensor[] Ta = new Tensor[N];
Ta[0] = makeTensor("", (0, 0),
  new Leg[] {phys[0], virt[0]}, primary_color, "circle");
for (int n = 1; n < N-1; n+=1) {
  Ta[n] = makeTensor("", (dist*n, 0),
    new Leg[] {phys[n], dag(virt[n-1]), virt[n]}, primary, "circle");
}
Ta[N-1] = makeTensor("", (dist*(N-1), 0),
  new Leg[] {phys[N-1], dag(virt[N-2])}, primary_color, "circle");

TensorNetwork net_a = makeTensorNetwork(Ta);

// Panel B: Split logical/gauge with 2N tensors
// Top row: gauge tensors with external gauge legs
// Bottom row: logical tensors chained together
int dim_log = 2;
int dim_gauge = round(dim_phys/2);
int dim_gauge_log = 6;
real gauge_y = -50;
real gauge_x_offset = -20;

Leg[] gauge_ext = new Leg[N];
Leg[] logical_ext = new Leg[N];
Leg[] gauge_log_bond = new Leg[N];
Leg[] log_bond = new Leg[N-1];

for (int n = 0; n < N; n+=1) {
  gauge_ext[n] = makeLeg("ge" + string(n), (0, 1), dim=dim_gauge,
    label="$i_{{\rm j}," + numerical_label(n, N) + "}$", side=-1);
  logical_ext[n] = makeLeg("le" + string(n), (0, 1), dim=dim_log,
     side=-1,
    label="$i_{{l}," + numerical_label(n, N) + "}$");
  gauge_log_bond[n] = makeLeg("glb" + string(n), (1, 1),
    allowBezier=false, labelStrength=0, dim=dim_gauge_log);
}

for (int n = 0; n < N-1; n+=1) {
  string label = "";
  int labelStrength = 0;
  if (n == round(N/2)-1) {
    label = "$\cdots$";
    labelStrength = 1;
  }
  log_bond[n] = makeLeg("lb" + string(n), (1, 0), allowBezier=false,
    label=label, labelStrength=labelStrength, dim=dim_log, side=-1);
}

Tensor[] Gb = new Tensor[N];
for (int n = 0; n < N; n+=1) {
  Gb[n] = makeTensor("", (dist_split*n + gauge_x_offset, gauge_y),
    new Leg[] {gauge_ext[n], gauge_log_bond[n]}, gauge_color, "circle");
}

Tensor[] Lb = new Tensor[N];
Lb[0] = makeTensor("", (0, 0),
  new Leg[] {logical_ext[0], dag(gauge_log_bond[0]), log_bond[0]}, logical_color, "circle");
for (int n = 1; n < N-1; n+=1) {
  Lb[n] = makeTensor("", (dist_split*n, 0),
    new Leg[] {logical_ext[n], dag(gauge_log_bond[n]), log_bond[n-1], log_bond[n]}, logical_color, "circle");
}
Lb[N-1] = makeTensor("", (dist_split*(N-1), 0),
  new Leg[] {logical_ext[N-1], dag(gauge_log_bond[N-1]), log_bond[N-2]}, logical_color, "circle");

TensorNetwork net_b = makeTensorNetwork(concat(Gb, Lb));

// Draw each panel into its own picture
picture pic_a;
currentpicture = pic_a;
draw(net_a);

picture pic_b;
currentpicture = pic_b;
draw(net_b);

currentpicture = old;

// Compose panels side by side with an arrow
real gap_arrow = 15;
real arrow_length = 40;
real[] kerning = new real[] {0};

picture[] pics = new picture[] {pic_a, pic_b};
real total_offset = 0;
for (int i = 0; i < pics.length; i+=1) {
  total_offset += -min(pics[i]).x;
  attach(pics[i].fit(), (total_offset, -(max(pics[i]).y + min(pics[i]).y)/2));
  if (i < pics.length - 1) {
    pair a = (total_offset + max(pics[i]).x + gap_arrow, 0);
    pair b = a + (arrow_length, 0);
    draw(a--b, defaultLegColor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));
    total_offset += kerning[i];
  }
  total_offset += max(pics[i]).x + 2*gap_arrow + arrow_length;
}

shipoutWithMargin(2*lw + 2*gap, background);
