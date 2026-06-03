include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

usepackage("amsmath");
// usepackage("amssymb");
usepackage("physics");

externalLegLength = 20 ;
legscale = 6;

Leg i_sys = makeLeg("i_sys", (0, 1));
Leg i_env = makeLeg("i_env", (0, 1),dim=10);
Leg i_sys_p = makeLeg("i_{\rm sys}", (0, 1), side=-1);
Leg i_env_p = makeLeg("i_{\rm env}", (0, 1),dim=10);

Leg i_sys_s = makeLeg("i_sys_s", (0, -1));
Leg i_env_s = makeLeg("i_env_s", (0, -1),dim=10);
Leg i_sys_p_s = makeLeg("i_{\rm sys}'", (0, -1));
Leg i_env_p_s = makeLeg("i_{\rm env}^*", (0, -1),dim=10, side=-1);

Leg a = makeLeg("a", (0, 1), allowBezier=false);
Leg b = makeLeg("b", (0, 1), allowBezier=false);

Tensor psi_sys = makeTensor("$\psi_{\rm sys}$", (-20,25/2), new Leg[] {i_sys}, primary, "circle");
Tensor psi_env = makeTensor("$\psi_{\rm env}$", (20,25/2), new Leg[] {i_env}, primary, "circle");
Tensor inter = makeTensor("$\mathcal{U}_{\rm int}$", (0,60), new Leg[] {dag(i_sys), dag(i_env), i_sys_p, i_env_p}, secondary, "rect", r=30, ratio=0.5);
Tensor inter_prime = makeTensor("$\mathcal{U}_{\rm int}'$", inter.pos, new Leg[] {dag(i_sys), i_sys_p, i_env_p}, secondary, "rect", r=30, ratio=0.5);

Tensor psi_env_dag = makeTensor("$\psi_{\rm env}^*$", (20,-25/2), new Leg[] {i_env_s}, primary, "circle");
Tensor psi_sys_dag = makeTensor("$\psi_{\rm sys}^*$", (-20,-25/2), new Leg[] {i_sys_s}, primary, "circle");
Tensor inter_dag = makeTensor("$\mathcal{U}_{\rm int}^\dagger$", -inter.pos, new Leg[] {dag(i_env_s), dag(i_sys_s), i_env_p_s, i_sys_p_s}, secondary, "rect", r=30, ratio=0.5);
Tensor inter_prime_dag = makeTensor("$\left(\mathcal{U}_{\rm int}^\dagger\right)'$", -inter_prime.pos, new Leg[] {dag(i_sys_s), i_env_p_s, i_sys_p_s}, secondary, "rect", r=30, ratio=0.5);
Tensor v_id = makeTensor("\hspace{20pt}j", (40,0), new Leg[] {i_env_p_s, i_env_p}, "id_v", r = 70, dim=10);

Tensor K = makeTensor("$\mathcal{K}_j$", (psi_sys.pos.x,inter.pos.y), new Leg[] {dag(i_sys), i_sys_p}, secondary, "square");
Tensor K_dag = makeTensor("$\mathcal{K}_j^\dagger$", (psi_sys.pos.x,-inter.pos.y), new Leg[] {dag(i_sys_s), i_sys_p_s}, secondary, "square");

Tensor psi_p = makeTensor("$\psi_{j}$", psi_sys.pos, new Leg[] {i_sys_p}, primary, "circle");
Tensor psi_p_dag = makeTensor("$\psi_{j}^*$", psi_sys_dag.pos, new Leg[] {i_sys_p_s}, primary, "circle");

TensorNetwork net = makeTensorNetwork(new Tensor[] {psi_sys, psi_sys_dag, psi_env, psi_env_dag, inter, inter_dag});
TensorNetwork traced = makeTensorNetwork(new Tensor[] {psi_sys, psi_sys_dag, inter_prime, inter_prime_dag, v_id});
TensorNetwork krauss = makeTensorNetwork(new Tensor[] {psi_sys, psi_sys_dag, K, K_dag});
TensorNetwork state_prime = makeTensorNetwork(new Tensor[] {psi_p, psi_p_dag});

picture old = currentpicture;

picture interaction_pic;
currentpicture = interaction_pic;
draw(net);
// shipoutWithMargin(2*lw + 2*gap);


picture interaction_pic_2;
currentpicture = interaction_pic_2;
psi_env.pos += (0, 5);
psi_env_dag.pos += (0, -5);
draw(net);


picture traced_pic;	
currentpicture = traced_pic;
// change the position of the system tensor to be more centered
psi_sys.pos = (0, 25/2);
psi_sys_dag.pos = (0, -25/2);
draw(traced);

picture krauss_pic;
currentpicture = krauss_pic;
// put them back
psi_sys.pos = (-20,25/2);
psi_sys_dag.pos = (-20,-25/2);
draw(krauss);
// Draw summation over j symbol with a large fontsize
label("$\begin{aligned}\sum_j\end{aligned}$", (-60,-7.5), fontsize(20));

picture state_prime_pic;
currentpicture = state_prime_pic;
label("$\begin{aligned}\sum_j\end{aligned}$", (-60,-7.5), fontsize(20));
draw(state_prime);

currentpicture = old;
attach(interaction_pic.fit(), (0,0));
attach(interaction_pic_2.fit(), (150,0));
attach(traced_pic.fit(), (300,0));
attach(krauss_pic.fit(), (475,0));
attach(state_prime_pic.fit(), (600,0));

// arrows between pictures
int fontsize = 24;
label("$=$", (75,0), fontsize(fontsize));
label("$\xrightarrow{\rm{Tr_{env}}}$", (225,0), fontsize(fontsize));
label("$=$", (380,0), fontsize(fontsize));
label("$=$", (500,0), fontsize(fontsize));



shipoutWithMargin(2*lw + 2*gap, background);