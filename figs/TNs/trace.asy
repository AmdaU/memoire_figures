include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

externalLegLength = 20;

Leg i = makeLeg("i", (-1, 0));
Leg j = makeLeg("j", (1, 0));

Tensor A = makeTensor("$A$", (0,0), new Leg[] {i, j}, primary, "square");
Tensor B = makeTensor("", (0,30), new Leg[] {j, i}, "id_h");


TensorNetwork net = makeTensorNetwork(new Tensor[] {A, B});
draw(net);
shipoutWithMargin(2*lw + 2*gap, background);
