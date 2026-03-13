%% Symbolic linearisation of your model: xdot = f(x,u)

import sym.*

%% 1) States and inputs (match your indexing)
syms i_d i_q i i_d_i i_q_i v_d_i v_q_i i_i v_i p_sum_i p_delta_i v_lk v_r w theta real
x = [ i_d; i_q; i; i_d_i; i_q_i; v_d_i; v_q_i; i_i; v_i; p_sum_i; p_delta_i; v_lk; v_r; w; theta ];

syms v_d v_q v real
u = [ v_d; v_q; v ];

%% 2) Parameters / references (everything used in your snippet)
syms Rac Lac Rdc Ldc real
syms kp_sum ki_sum kp_lk ki_lk real
syms D_dc D_ac real
syms VLK0 W0 V0 wa real
syms C_lk real
syms kp_v_dq ki_v_dq kp_i_dq ki_i_dq real
syms kp_v ki_v kp_i ki_i real
syms Rov Xov beta real
syms v_d_r v_q_r real

p = [Rac;Lac;Rdc;Ldc;kp_sum;ki_sum;kp_lk;ki_lk;D_dc;D_ac;VLK0;W0;V0;wa;C_lk; ...
     kp_v_dq;ki_v_dq;kp_i_dq;ki_i_dq;kp_v;ki_v;kp_i;ki_i;Rov;Xov;beta;v_d_r;v_q_r];

%% 3) Recreate your algebra (same naming as you used)

% Power Measurement
p_dc = (v*i)*(-1);
p_ac = (v_d*i_d + v_q*i_q)*(-1);

% Interlink Control
p_bal     = (v - V0) - beta * (w - W0)/(2*pi);
p_sum_r   = p_bal * kp_sum + p_sum_i;
dp_sum_i  = p_bal * ki_sum;

p_delta_r    = (v_lk - VLK0) * kp_lk + p_delta_i;
dp_delta_i   = (v_lk - VLK0) * ki_lk;

p_dc_r = p_delta_r - p_sum_r;
p_ac_r = p_delta_r + p_sum_r;

% AC droop
dw   = (D_ac * (p_ac_r - p_ac) + W0 - w)*wa;

% DC droop
dv_r = (D_dc * (p_dc_r - p_dc) + V0 - v_r)*wa;

% AC voltage control
error_v_d = v_d_r - v_d - (i_d*Rov - i_q*Xov)*(-1);
error_v_q = v_q_r - v_q - (i_q*Rov + i_d*Xov)*(-1);

i_d_r = -(error_v_d*kp_v_dq + v_d_i);
i_q_r = -(error_v_q*kp_v_dq + v_q_i);

dv_d_i = error_v_d*ki_v_dq;
dv_q_i = error_v_q*ki_v_dq;

% AC current control
error_i_d = i_d_r - i_d;
error_i_q = i_q_r - i_q;

e_d   = -error_i_d*kp_i_dq + i_d_i;
e_q   = -error_i_q*kp_i_dq + i_q_i;

di_d_i = -error_i_d*ki_i_dq;
di_q_i = -error_i_q*ki_i_dq;

% DC voltage control
error_v = v_r - v;
i_r     = -(error_v*kp_v + v_i);
dv_i    = error_v*ki_v;

% DC current control
error_i = i_r - i;
e_dc    = -error_i*kp_i + i_i;
di_i    = -error_i*ki_i;

% Link dynamics
i_lk_dc = p_dc/v_lk;
i_lk_ac = p_ac/v_lk;
i_lk    = - i_lk_dc - i_lk_ac;
dv_lk   = i_lk/C_lk;

% Angle dynamics
dtheta = w;

% AC filter inductor
di_d = (v_d - Rac*i_d + w*Lac*i_q - e_d)/Lac;
di_q = (v_q - Rac*i_q - w*Lac*i_d - e_q)/Lac;

% DC filter inductor
di = (v - Rdc*i - e_dc)/Ldc;

%% 4) Build f(x,u) in the SAME ORDER as x
f = [ di_d;
      di_q;
      di;
      di_d_i;
      di_q_i;
      dv_d_i;
      dv_q_i;
      di_i;
      dv_i;
      dp_sum_i;
      dp_delta_i;
      dv_lk;
      dv_r;
      dw;
      dtheta ];

%% 5) Linearisation: A = df/dx, B = df/du
A = jacobian(f, x);
B = jacobian(f, u);

% (optional) simplify
A = simplify(A, 'Steps', 50);
B = simplify(B, 'Steps', 50);

%% 6) Evaluate at an operating point (x0,u0) + parameter values p0
% Fill these in from your Equilibrium() routine:
% x0 = [...]; u0 = [...]; p0 = [...];
x0 = x_e{2};
u0 = u_e{2};
p0 = [ApparatusPara{2};0.01/0.003;1;0];
% Example placeholders (DO NOT use as-is):
% x0 = zeros(15,1); u0 = zeros(3,1); p0 = ones(length(p),1);

A0 = double(subs(A, [x; u; p], [x0; u0; p0]));
B0 = double(subs(B, [x; u; p], [x0; u0; p0]));

%% 7) Or create fast numeric functions
Af = matlabFunction(A, 'Vars', {x, u, p});
Bf = matlabFunction(B, 'Vars', {x, u, p});
