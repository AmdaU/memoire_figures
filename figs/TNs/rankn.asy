include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

externalLegLength = 20;

Leg i = makeLeg("i", (-1, 0.5));
Leg j = makeLeg("j", (-1, -0.5), side=-1);
Leg k = makeLeg("k", (1, 0.5), side=-1);
Leg l = makeLeg("l", (1, -0.5));

Tensor A = makeTensor("$T$", (0,0), new Leg[] {i, j, k, l}, primary);


TensorNetwork net = makeTensorNetwork(new Tensor[] {A});
draw(net);
shipoutWithMargin(2*lw + 2*gap, background);