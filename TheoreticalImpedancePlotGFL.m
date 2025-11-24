% This function obtains the State Space Representation of Interlinking
% Converter for either Type 2000 Power Setpoint or Type 2001 DC Voltage
% Control Gri_d-Following VSC.
function theoreticalSS = TheoreticalImpedancePlotGFL(x_e, u_e, Para, ApparatusPowerFlow, ApparatusImpedancePlotSelect)
    k = ApparatusImpedancePlotSelect;

%% Obtain Parameters
% Get the power PowerFlow values
            P0 	= ApparatusPowerFlow{k}(1);
            Q0	= ApparatusPowerFlow{k}(2);
            V0	= ApparatusPowerFlow{k}(3);
            xi	= ApparatusPowerFlow{k}(4);
            w0  = ApparatusPowerFlow{k}(5);
            
           	% Get parameters
            C_dc        = Para{k}.C_dc;
            v_dc_r      = Para{k}.V_dc;
            f_v_dc      = Para{k}.f_v_dc;
            f_pll       = Para{k}.f_pll;     
            f_tau_pll   = Para{k}.f_tau_pll;
            f_i_dq      = Para{k}.f_i_dq; 
            wLf         = Para{k}.wLf;
            R           = Para{k}.R;
            W0          = Para{k}.w0;
            
            % Filter inductor
            Lf = wLf/W0;
            
            % Dc link controller parameter
            w_v_dc   = f_v_dc*2*pi;
            kp_v_dc	= v_dc_r*C_dc*w_v_dc;
            ki_v_dc	= kp_v_dc*w_v_dc/4;
            
            % PLL controller parameter
            w_pll     = f_pll*2*pi;
            kp_pll    = w_pll;
            ki_pll    = kp_pll * w_pll/4;
            w_tau_pll = f_tau_pll*2*pi;
            tau_pll   = 1/w_tau_pll;
            
            % Current controller paramter
            w_i_dq  = f_i_dq*2*pi;
            kp_i_dq = Lf * w_i_dq;
            ki_i_dq = Lf * w_i_dq^2 /4;
            
            % Notes:
            % kp = w*L, ki = w^2*L/4. These values can ensure the current
            % loop is approximately a critically damped second order system
            % with a bandwi_dth w. Other PI controllers can be designed
            % similarly.
            
            % Get states
          	i_d   	= x_e{k}(1);
         	i_q   	= x_e{k}(2);
          	i_d_i  	= x_e{k}(3);
            i_q_i 	= x_e{k}(4);
            w_pll_i = x_e{k}(5);
            w       = x_e{k}(6);
            theta   = x_e{k}(7);
            v_dc  	= x_e{k}(8);
            v_dc_i 	= x_e{k}(9);

            % Get input
        	v_d    = u_e{k}(1);
            v_q    = u_e{k}(2);
            ang_r  = u_e{k}(3);
            P_dc   = u_e{k}(4);
            
            %% Precompute control voltages at OP (needed for linearisation)
            i_d_r = (v_dc_r - v_dc)* ki_v_dc;
            ed0 = kp_i_dq*(i_d_r - i_d) + i_d_i;
            eq0 = kp_i_dq*(0 - i_q) + i_q_i;
            % Power balance term
            N0 = ed0*i_d + eq0*i_q - P_dc;   % often ~ 0
%% Build matrices
A = zeros(9);
B = zeros(9,4);

%% -------- AC CURRENT DYNAMICS --------
A(1,1) = -(R + kp_i_dq)/Lf;
A(1,2) = w;
A(1,3) = -1/Lf;
A(1,6) = i_q;
A(1,8) = -(kp_i_dq*kp_v_dc)/Lf;
A(1,9) =  kp_i_dq / Lf;
B(1,1) = 1/Lf;

A(2,1) = -w;
A(2,2) = -(R + kp_i_dq)/Lf;
A(2,4) = -1/Lf;
A(2,6) = -i_d;
B(2,2) = 1/Lf;

%% -------- CURRENT PI INTEGRATORS --------
A(3,1) = ki_i_dq;
A(3,8) = ki_i_dq * kp_v_dc;
A(3,9) = -ki_i_dq;

A(4,2) = ki_i_dq;

%% -------- PLL --------
% wi_dot = ki_pll*(vq - ang_r)
B(5,2) =  ki_pll;
B(5,3) = -ki_pll;

% w_dot = (wi + (vq - ang_r)*kp_pll - w)/tau
A(6,5) =  1/tau_pll;
A(6,6) = -1/tau_pll;
B(6,2) =  kp_pll / tau_pll;
B(6,3) = -kp_pll / tau_pll;

% theta_dot = w
A(7,6) = 1;

%% -------- DC-LINK DYNAMICS --------
A(8,1) = (ed0 - i_d*kp_i_dq)/(C_dc*v_dc);
A(8,2) = (eq0 - i_q*kp_i_dq)/(C_dc*v_dc);
A(8,3) = i_d/(C_dc*v_dc);
A(8,4) = i_q/(C_dc*v_dc);

A(8,8) = -(N0 + i_d*kp_i_dq*kp_v_dc*v_dc)/(C_dc*v_dc^2);
A(8,9) =  i_d*kp_i_dq/(C_dc*v_dc);

B(8,4) = -1/(C_dc*v_dc);

%% -------- OUTER DC-LINK PI --------
A(9,8) = -ki_v_dc;

%% -------- OUTPUT MATRICES --------
C = [ 1 0 0 0 0 0 0 0 0;
      0 1 0 0 0 0 0 0 0;
      0 0 0 0 0 1 0 0 0;
      0 0 0 0 0 0 0 1 0;
      0 0 0 0 0 0 1 0 0 ];

D = zeros(5,4);
theoreticalSS = ss(A,B,C,D);

end