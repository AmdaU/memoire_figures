include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

externalLegLength = 20 ;
legscale = 6;

Leg i_sys = makeLeg("i_sys", (0, 1));
Leg i_env = makeLeg("i_env", (0, 1),dim=10);
Leg i_sys_p = makeLeg("i_{\rm sys}", (0, 1), side=-1);
Leg i_env_p = makeLeg("i_{\rm env}", (0, 1),dim=10);

Tensor psi_sys = makeTensor("$\psi_{\rm sys}$", (-20,0), new Leg[] {i_sys}, primary, "circle");
Tensor psi_env = makeTensor("$\psi_{\rm env}$", (20,0), new Leg[] {i_env}, primary, "circle");
Tensor inter = makeTensor("$U_{\rm int}$", (0,60), new Leg[] {dag(i_sys), dag(i_env), i_sys_p, i_env_p}, secondary, "rect", r=30, ratio=0.5);


TensorNetwork net = makeTensorNetwork(new Tensor[] {psi_sys, psi_env, inter});
draw(net);
shipoutWithMargin(2*lw + 2*gap, background);
