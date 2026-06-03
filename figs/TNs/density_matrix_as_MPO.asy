import settings;
outformat = "pdf";
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

picture old = currentpicture;
externalLegLength = 15;
legscale = 2;

int n = 4;        // tensors per chain
real dist = 50;   // horizontal spacing between tensors
real vert = 15;   // vertical offset top/bottom MPS from center
int vdim = 4;     // virtual bond dimension
int pdim = 15;    // physical leg dimension

// ===== Panel 1: Two stacked MPS =====
// Top MPS: squares, physical legs UP (ket)
// Bottom MPS: squares, physical legs DOWN (bra)

Leg[] vtop = new Leg[n-1];
Leg[] vbot = new Leg[n-1];
for (int k = 0; k < n-1; k+=1) {
  vtop[k] = makeLeg("vt" + string(k), (-1, 0), allowBezier=false, labelStrength=0, dim=vdim);
  vbot[k] = makeLeg("vb" + string(k), (-1, 0), allowBezier=false, labelStrength=0, dim=vdim);
}

Tensor[] T_top = new Tensor[n];
Tensor[] T_bot = new Tensor[n];
for (int k = 0; k < n; k+=1) {
  Leg pu = makeLeg("tu" + string(k), (0,  1), dim=pdim, labelStrength=0);
  Leg pd = makeLeg("bd" + string(k), (0, -1), dim=pdim, side=-1, labelStrength=0);
  Leg[] lt; Leg[] lb;
  lt.push(pu);
  lb.push(pd);
  if (k > 0)   { lt.push(vtop[k-1]);      lb.push(vbot[k-1]); }
  if (k < n-1) { lt.push(dag(vtop[k]));   lb.push(dag(vbot[k])); }
  T_top[k] = makeTensor("$\psi_{" + string(k) + "}$", (k*dist,  vert), lt, primary,   "square");
  T_bot[k] = makeTensor("$\psi_{" + string(k) + "}^\dagger$", (k*dist, -vert), lb, secondary, "square");
}

Tensor[] all_p1;
for (int k = 0; k < n; k+=1) { all_p1.push(T_top[k]); all_p1.push(T_bot[k]); }
TensorNetwork net_p1 = makeTensorNetwork(all_p1);

// ===== Panel 2: MPO with double virtual bonds =====
// Each site has physical legs up AND down, plus two virtual bonds per side
// (one from top MPS, one from bottom MPS) — shown as double horizontal lines

Leg[] v2a = new Leg[n-1]; // from top MPS virtual bond
Leg[] v2b = new Leg[n-1]; // from bottom MPS virtual bond
for (int k = 0; k < n-1; k+=1) {
  v2a[k] = makeLeg("w2a" + string(k), (-1, 0), allowBezier=true, labelStrength=0, dim=vdim);
  v2b[k] = makeLeg("w2b" + string(k), (-1, 0), allowBezier=true, labelStrength=0, dim=vdim);
}

Tensor[] T_p2 = new Tensor[n];
for (int k = 0; k < n; k+=1) {
  Leg pu = makeLeg("p2u" + string(k), (0,  1), dim=pdim, labelStrength=0);
  Leg pd = makeLeg("p2d" + string(k), (0, -1), dim=pdim, side=-1, labelStrength=0);
  Leg[] legs;
  legs.push(pu);
  legs.push(pd);
  if (k > 0)   { legs.push(v2a[k-1]);      legs.push(v2b[k-1]); }
  if (k < n-1) { legs.push(dag(v2a[k]));   legs.push(dag(v2b[k])); }
  T_p2[k] = makeTensor("", (k*dist, 0), legs, secondary, "rect", ratio=2);
}
TensorNetwork net_p2 = makeTensorNetwork(T_p2);

// ===== Panel 3: Clean MPO — double bonds merged into one wider bond =====

Leg[] v3 = new Leg[n-1];
for (int k = 0; k < n-1; k+=1) {
  v3[k] = makeLeg("w3" + string(k), (-1, 0), allowBezier=false, labelStrength=0, dim=vdim*vdim);
}

Tensor[] T_p3 = new Tensor[n];
for (int k = 0; k < n; k+=1) {
  Leg pu = makeLeg("p3u" + string(k), (0,  1), dim=pdim, labelStrength=0);
  Leg pd = makeLeg("p3d" + string(k), (0, -1), dim=pdim, side=-1, labelStrength=0);
  Leg[] legs;
  legs.push(pu);
  legs.push(pd);
  if (k > 0)   legs.push(v3[k-1]);
  if (k < n-1) legs.push(dag(v3[k]));
  T_p3[k] = makeTensor("", (k*dist, 0), legs, secondary, "square");
}
TensorNetwork net_p3 = makeTensorNetwork(T_p3);

// ===== Render each panel into its own picture =====

picture pic_p1;
currentpicture = pic_p1;
draw(net_p1);

picture pic_p2;
currentpicture = pic_p2;
draw(net_p2);
// Overdraw rect bodies with a top(primary) → bottom(secondary) gradient
for (int k = 0; k < n; k+=1) {
  pair pos = (k*dist, 0);
  path body = shift(pos)*box((-r, -r*2), (r, r*2));
  axialshade(body, primary, pos+(0, r*2), secondary, pos+(0, -r*2));
  draw(body, linewidth(lw) + defaultLegColor);
  label("$\rho_{" + string(k) + "}$", pos, defaultLegColor);
}

picture pic_p3;
currentpicture = pic_p3;
draw(net_p3);
// Overdraw square bodies with the same gradient
for (int k = 0; k < n; k+=1) {
  pair pos = (k*dist, 0);
  path body = box(pos-(r,r), pos+(r,r));
  axialshade(body, primary, pos+(0, r), secondary, pos+(0, -r));
  draw(body, linewidth(lw) + defaultLegColor);
  label("$\rho_{" + string(k) + "}$", pos, defaultLegColor);
}

currentpicture = old;

// ===== Lay out panels left-to-right with arrows between them =====

real gap_arr  = 8;
real arr_len  = 30;
real total_x  = 0;
picture[] pics = new picture[] {pic_p1, pic_p2, pic_p3};

for (int i = 0; i < pics.length; i+=1) {
  attach(pics[i].fit(), (total_x, 0));
  if (i < pics.length - 1) {
    pair a = (total_x + max(pics[i]).x + gap_arr, 0);
    pair b = a + (arr_len, 0);
    draw(a--b, defaultLegColor + linewidth(1.5), arrow=Arrow(TeXHead, size=1mm));
    total_x += -min(pics[i+1]).x;
  }
  total_x += max(pics[i]).x + 2*gap_arr + arr_len;
}

shipoutWithMargin(2*lw + 2*gap, background);
