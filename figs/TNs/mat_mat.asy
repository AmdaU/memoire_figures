include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

externalLegLength = 20;

Leg i = makeLeg("i", (-1, 0), side=-1);
Leg j = makeLeg("j", allowBezier=false);
Leg k = makeLeg("k", (1, 0));

Tensor A = makeTensor("$A$", (0,0), new Leg[] {i, j}, primary, "square");
Tensor B = makeTensor("$B$", (45,0), new Leg[] {dag(j), k}, secondary, "square");


TensorNetwork net = makeTensorNetwork(new Tensor[] {A, B});
draw(net);
shipoutWithMargin(2*lw + 2*gap, background);
