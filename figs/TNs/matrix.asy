include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

externalLegLength = 20;

Leg i = makeLeg("i", (1, 0), side=-1);
Leg j = makeLeg("j", (-1, 0));
Tensor A = makeTensor("$M$", (0,0), new Leg[] {i, j}, primary);


TensorNetwork net = makeTensorNetwork(new Tensor[] {A});
draw(net);
shipoutWithMargin(2*lw + 2*gap, background);