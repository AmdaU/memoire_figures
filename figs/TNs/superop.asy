include "figs/TN.asy";
include "figs/AutoColors.asy.tmp";
defaultLegColor = textcolor;
defaultpen(fontsize(12pt) + defaultLegColor);

usepackage("amsmath");
// usepackage("amssymb");
usepackage("physics");

externalLegLength = 20 ;
legscale = 6;
real dist = 40;
int fontsize = 30;
real r_outer = 70;
real r_inner = 50;
real straight_length = 20;

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

pair center = (psi_sys.pos.x, 0);

path c_outer = arc(center, r_outer, -90, 90);
path c_inner = arc(center, r_inner, 90, -90);
// join the outer and inner arcs with a smaller arc
path c_link = arc(center +(0,(r_outer+r_inner)/2), (r_outer-r_inner)/2, -270, 270);
path c_link_2 = shift((0,-(r_outer+r_inner)))*c_link;

c_link = shift((-straight_length/2,0))*c_link;
c_link_2 = shift((-straight_length/2,0))*c_link_2;

path c = c_outer -- c_link -- c_inner -- c_link_2 -- cycle;


pair port_i = (psi_sys.pos.x, -r_inner);
pair port_j = (psi_sys.pos.x, r_inner);
pair port_i_2 = (psi_sys.pos.x, -r_outer);
pair port_j_2 = (psi_sys.pos.x, r_outer);
Tensor L = makeTensor("$\mathcal{L}$", (0,0), new Leg[] {dag(i_sys_s), dag(i_sys), i_sys_p_s, i_sys_p}, secondary, "blob", blob=c, blob_ports=new pair[] {port_i, port_j, port_i_2, port_j_2}, blob_label_pos=(center + ((r_outer+r_inner)/2,0)));


Tensor psi_p = makeTensor("$\psi_{j}$", psi_sys.pos, new Leg[] {i_sys_p}, primary, "circle");
Tensor psi_p_dag = makeTensor("$\psi_{j}^*$", psi_sys_dag.pos, new Leg[] {i_sys_p_s}, primary, "circle");



Leg i_sys_rot = makeLeg("i_{\rm sys}", (1, 0));
Leg i_sys_s_rot = makeLeg("i_{\rm sys}^*", (1, 0));
Leg i_sys_p_s_rot = makeLeg("i_{\rm sys}'", (1, 0));
Leg i_sys_p_rot = makeLeg("i_{\rm sys}^{*\prime}", (1, 0));

Tensor psi_sys_rot = makeTensor("$\psi_{\rm sys}$", (0,psi_sys.pos.y), new Leg[] {i_sys_rot}, primary, "circle");
Tensor psi_sys_dag_rot = makeTensor("$\psi_{\rm sys}^*$", (0,psi_sys_dag.pos.y), new Leg[] {i_sys_s_rot}, primary, "circle");

pair center_rot = (0, 0);
real L_rot_length = 50;
path c_upper = arc(center_rot + (0, L_rot_length/2), L_rot_length/4, 180, 0);
path c_lower = arc(center_rot + (0, -L_rot_length/2), L_rot_length/4, -0, -180);

path c_rot = c_upper -- c_lower -- cycle;

pair port_in_1 = (-L_rot_length/4, center_rot.y + psi_sys.pos.y);
pair port_in_2 = (L_rot_length/4, center_rot.y - psi_sys.pos.y);
pair port_out_1 = (L_rot_length/4, center_rot.y + psi_sys.pos.y);
pair port_out_2 = (L_rot_length/4, center_rot.y - psi_sys.pos.y);


Tensor L_rot = makeTensor("$\mathcal{L}$", (50,0), new Leg[] {dag(i_sys_rot), dag(i_sys_s_rot), i_sys_p_s_rot, i_sys_p_rot}, secondary, "blob", blob=c_rot, blob_ports=new pair[] {port_in_1, port_in_2, port_out_1, port_out_2});

Leg i_sys_combined = makeLeg("i_{\rm sys}", (1, 0), allowBezier=false, dim=4);	
Leg i_sys_combined_p = makeLeg("i_{\rm sys}'", (1, 0), allowBezier=false, dim=4);

Tensor rho_sys = makeTensor("$\rho_{\rm sys}$", (0,0), new Leg[] {i_sys_combined}, primary, "circle");

Tensor super_combined = makeTensor("$\mathcal{L}$", (50,0), new Leg[] {dag(i_sys_combined), i_sys_combined_p}, secondary, "square");

TensorNetwork net = makeTensorNetwork(new Tensor[] {psi_sys, psi_sys_dag, psi_env, psi_env_dag, inter, inter_dag});
TensorNetwork traced = makeTensorNetwork(new Tensor[] {psi_sys, psi_sys_dag, inter_prime, inter_prime_dag, v_id});
TensorNetwork superoperator = makeTensorNetwork(new Tensor[] {psi_sys, psi_sys_dag, L});

TensorNetwork rot = makeTensorNetwork(new Tensor[] {psi_sys_rot, psi_sys_dag_rot, L_rot});

TensorNetwork combined = makeTensorNetwork(new Tensor[] {rho_sys, super_combined});



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
// change the position of the system tensor to be more centered
psi_sys.pos = (0, 25/2);
psi_sys_dag.pos = (0, -25/2);
currentpicture = traced_pic;
draw(traced);

picture superoperator_pic;
// put them back
psi_sys.pos = (-20,25/2);
psi_sys_dag.pos = (-20,-25/2);
currentpicture = superoperator_pic;
draw(superoperator);

picture rot_pic;
currentpicture = rot_pic;
draw(rot);

picture combined_pic;
currentpicture = combined_pic;
draw(combined);

currentpicture = old;
attach(interaction_pic.fit(), (0,0));
attach(interaction_pic_2.fit(), (150,0));
attach(traced_pic.fit(), (300,0));
attach(superoperator_pic.fit(), (450,0));
attach(rot_pic.fit(), (575,0));
attach(combined_pic.fit(), (725,0));
// arrows between pictures
int fontsize = 24;
label("$=$", (75,0), fontsize(fontsize) + textcolor);
label("$\xrightarrow{\rm{Tr_{env}}}$", (225,0), fontsize(fontsize) + textcolor);
label("$=$", (380,0), fontsize(fontsize) + textcolor);
label("$=$", (530,0), fontsize(fontsize) + textcolor);
label("$=$", (690,0), fontsize(fontsize) + textcolor);



shipoutWithMargin(2*lw + 2*gap, background);
