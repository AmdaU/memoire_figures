import settings;
outformat = "pdf";
include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

picture old = currentpicture;
externalLegLength = 15;

int N = 5; 
real dist = 40;
pen color = secondary;

Leg[] is = new Leg[N];
Leg[] is_p = new Leg[N];
Leg[] virts = new Leg[N];
for (int n = 0; n < N; n+=1) {
  is[n] = makeLeg("i'_" + string(n+1), (0, 1));
  is_p[n] = makeLeg("i_" + string(n+1), (0, -1), side=-1);
}
for (int n = 0; n < N-1; n+=1) {
  virts[n] = makeLeg("virt_" + string(n), (1,0), allowBezier=false, labelStrength=0);
}

Tensor[] Ts = new Tensor[N];
//Ts[0] = makeTensor("$T_{0}$", (0,0), new Leg[] {is[0], virts[0]}, primary, "circle");
Ts[0] = makeTensor("", (0,0), new Leg[] {is[0], is_p[0], virts[0]}, color, "circle");

for (int n = 1; n < N-1; n+=1) {
  //Ts[n] = makeTensor("$T_{" + string(n) + "}$", (n*dist,0), new Leg[] {is[n], virts[n - 1], virts[n]}, primary, "circle");
  Ts[n] = makeTensor("", (n*dist,0), new Leg[] {is[n], is_p[n], virts[n - 1], virts[n]}, color, "circle");
}
//Ts[N-1] = makeTensor("$T_{" + string(N-1) + "}$", ((N-1)*dist,0), new Leg[] {is[N-1], virts[N-2]}, primary, "circle");
Ts[N-1] = makeTensor("", ((N-1)*dist,0), new Leg[] {is[N-1], is_p[N-1], virts[N-2]}, color, "circle");

// TensorNetwork net = makeTensorNetwork(new Tensor[] {T0, T1});
// label(string(Ts), (0,0));

TensorNetwork net = makeTensorNetwork(Ts);
draw(net);
shipoutWithMargin(2*lw + 2*gap, background);