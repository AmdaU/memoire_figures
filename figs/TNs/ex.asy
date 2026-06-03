include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

externalLegLength = 20;

Leg a = makeLeg("a", (0, 1), allowBezier=false);
Leg b = makeLeg("b", (0, 1), allowBezier=false);

Leg i = makeLeg("i", (1, 0), allowBezier=false);
Leg j = makeLeg("j", (0, 1), allowBezier=false);
Leg k = makeLeg("k", (1, 0), allowBezier=false);
Leg l = makeLeg("l", (0, 1), allowBezier=false);
Leg m = makeLeg("m", side=-1, (0, -1), allowBezier=false);

Leg E1 = makeLeg("E1", (0, 1), allowBezier=false);
Leg E2 = makeLeg("E2", (0, 1), allowBezier=false);
Leg E3 = makeLeg("E3", (0, 1), allowBezier=false);

Tensor A = makeTensor("$A$", (-60,0), new Leg[] {a, i, j}, primary);
Tensor B = makeTensor("$B$", (0,0), new Leg[] {dag(i), k, l}, secondary);
Tensor C = makeTensor("$C$", (60,0), new Leg[] {dag(k), m, b}, tertiary);
Tensor D = makeTensor("$D$", (0,-60), new Leg[] {dag(m)}, primary);
Tensor E = makeTensor("$E$", (60,60), new Leg[] {E1, E2, E3}, primary);


TensorNetwork net = makeTensorNetwork(new Tensor[] {A, B, C, D});
TensorNetwork net2 = makeTensorNetwork(new Tensor[] {E});
draw(net);
draw(net2);
shipoutWithMargin(2*lw + 2*gap, background);