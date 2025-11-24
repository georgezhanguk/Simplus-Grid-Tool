% This function obtains the State Space Representation of Interlinking
% Converter for either Type 2000 Power Setpoint or Type 2001 DC Voltage
% Control Grid-Following VSC.
function theoreticalSS = TheoreticalImpedancePlot(x_e, u_e, Para, ApparatusPowerFlow, ApparatusImpedancePlotSelect, ApparatusType)
    k = ApparatusImpedancePlotSelect;
    if ApparatusType{k}==2000
        % printf('Type 2000')
    elseif ApparatusType{k}==2001
        % printf('Type 2001')
    else
        % printf('Apparatus Type is not supported')
    end
    %% Obtain Parameters
            % Get power flow
            P_ac    = ApparatusPowerFlow{k}(1);
            Vg_ac   = ApparatusPowerFlow{k}(3);
            Vg_dc   = ApparatusPowerFlow{k}(8);

            W0 = Para{k}.w0;
            C_dc = Para{k}.C_dc;
            L_ac = Para{k}.wL_ac/W0;
            R_ac = Para{k}.R_ac;
            L_dc = Para{k}.wL_dc/W0;
            R_dc = Para{k}.R_dc;
            xfidq = Para{k}.fidq;
            xfvdc = Para{k}.fvdc;
            xfpll = Para{k}.fpll;

            V_dc = 1;
            w_vdc   = xfvdc*2*pi; 	% (rad/s) bandwidth, vdc
            w_pll   = xfpll*2*pi;  	% (rad/s) bandwidth, pll
            w_i     = xfidq*2*pi; 	% (rad/s) bandwidth, idq
            w_tau_pll = 200*2*pi;   % (rad/s) PLL filter bandwidth
            
            kp_v_dc = V_dc*C_dc*w_vdc;
            ki_v_dc = kp_v_dc*w_vdc/4;
            kp_i_dq = L_ac * w_i;
            ki_i_dq = L_ac * w_i^2 /4;

            kp_pll = w_pll;
            ki_pll = kp_pll * w_pll/4;
            tau_pll = 1/w_tau_pll;

            i_d   	= x_e{k}(1);
            i_q   	= x_e{k}(2);
            i_d_i  	= x_e{k}(3);
            i_q_i 	= x_e{k}(4);
            w_pll_i = x_e{k}(5);
            w       = x_e{k}(6);
            theta   = x_e{k}(7);
            v_dc  	= x_e{k}(8);
            v_dc_i 	= x_e{k}(9);
            i       = x_e{k}(10);


            v_d    = u_e{k}(1);
            v_q    = u_e{k}(2);
            v      = u_e{k}(3);
            ang_r  = u_e{k}(4);

    % %% Obtain State Space Model 
    i_d_r = P_ac/Vg_ac;
    i_q_r = 0;
    E_d = -(i_d_r-i_d)*ki_i_dq + i_d_i;
    E_q = -(i_q_r-i_q)*ki_i_dq + i_q_i;
    E_de = i_d_i;
    E_qe = i_q_i;
    if ApparatusType{k}==2000
    %     printf('Type 2000')
    v_dc_to_v_dc_i = 0;
    v_dc_to_i_d_i = 0;
    v_dc_i_to_i_d_i = 0;
    v_dc_to_i_d = 0;
    v_dc_i_to_i_d = 0;
    v_dc_i_to_v_dc = 0;
    v_dc_to_v_dc = -(E_de*i_d+E_qe*i_q)/v_dc/C_dc;
    elseif ApparatusType{k}==2001
    %     printf('Type 2001')
    v_dc_to_v_dc_i = -ki_v_dc;
    v_dc_to_i_d_i = ki_i_dq*kp_v_dc;
    v_dc_i_to_i_d_i = -ki_i_dq;
    v_dc_to_i_d = -kp_i_dq*kp_v_dc/L_ac;
    v_dc_i_to_i_d = kp_i_dq/L_ac;
    v_dc_i_to_v_dc = -i_d*kp_i_dq/v_dc/C_dc;
    v_dc_to_v_dc = (-(E_de*i_d+E_qe*i_q)+kp_i_dq*kp_v_dc*i_d*v_dc)/v_dc/C_dc;
    else
    %     printf('Apparatus Type is not supported')
    end
    i_d_to_v_dc = (i_d*kp_i_dq+E_de)/v_dc/C_dc;
    % H1 = (-i_d_r*kp_i_dq+2*i_d*kp_i_dq+i_d_i)/v_dc/C_dc;
    i_q_to_v_dc = (i_q*kp_i_dq+E_qe)/v_dc/C_dc;
    i_d_i_to_v_dc = (i_d)/v_dc/C_dc;
    i_q_i_to_v_dc = (i_q)/v_dc/C_dc;

    A = [-(R_ac+kp_i_dq)/L_ac, w, -1/L_ac, 0, 0, i_q, 0, v_dc_to_i_d, v_dc_i_to_i_d, 0;
        -w, -(R_ac+kp_i_dq)/L_ac, 0, -1/L_ac, 0, -i_d, 0, 0, 0, 0;
        ki_i_dq, 0, 0, 0, 0, 0, 0, v_dc_to_i_d_i, v_dc_i_to_i_d_i, 0;
        0, ki_i_dq, 0, 0, 0, 0, 0, 0, 0, 0;
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
        0, 0, 0, 0, 1/tau_pll, -1/tau_pll, 0, 0, 0, 0;
        0, 0, 0, 0, 0, 1, 0, 0, 0, 0;
        i_d_to_v_dc, i_q_to_v_dc, i_d_i_to_v_dc , i_q_i_to_v_dc , 0, 0, 0, v_dc_to_v_dc, v_dc_i_to_v_dc, 1/C_dc;
        0, 0, 0, 0, 0, 0, 0, v_dc_to_v_dc_i, 0, 0;
        0, 0, 0, 0, 0, 0, 0, -1/L_dc, 0, -R_dc/L_dc;];
    B = [1/L_ac, 0, 0, 0;
        0, 1/L_ac, 0, 0;
        0, 0, 0, 0;
        0, 0, 0, 0;
        0, ki_pll, 0, -ki_pll;
        0, kp_pll/tau_pll, 0, -kp_pll/tau_pll; % error?
        0, 0, 0, 0;
        0, 0, 0, 0;
        0, 0, 0, 0;
        0, 0, 1/L_dc, 0;]; 
    C = [1 0 0 0 0 0 0 0 0 0;
        0 1 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 1;
        0 0 0 0 0 1 0 0 0 0;
        0 0 0 0 0 0 0 1 0 0;
        0 0 0 0 0 0 1 0 0 0;];
    D = zeros(6,4);
    %E = eye(size(A));
    theoreticalSS = ss(A,B,C,D);

end