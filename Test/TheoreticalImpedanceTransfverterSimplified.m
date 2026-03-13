% This function obtains the State Space Representation of Transfverter
function theoreticalSS = TheoreticalImpedanceTransfverterSimplified(x_e, u_e, ApparatusPara, ApparatusPowerFlow, k)
    %% Obtain Parameters
    VAC0        = ApparatusPowerFlow{k}(3);
    V0          = ApparatusPowerFlow{k}(8);

    Rac         = ApparatusPara{k}(1);
    Lac         = ApparatusPara{k}(2);
    Rdc         = ApparatusPara{k}(3);
    Ldc         = ApparatusPara{k}(4);
    kp_sum      = ApparatusPara{k}(5);
    ki_sum      = ApparatusPara{k}(6);
    kp_lk       = ApparatusPara{k}(7);
    ki_lk       = ApparatusPara{k}(8);
    D_dc        = ApparatusPara{k}(9);
    D_ac        = ApparatusPara{k}(10);
    VLK0        = ApparatusPara{k}(11);
    W0          = ApparatusPara{k}(12);
    wa          = ApparatusPara{k}(13);
    C_lk        = ApparatusPara{k}(14);
    
    beta        = D_dc/D_ac;

	% Get states
    i_d   	    = x_e{k}(1);
    i_q   	    = x_e{k}(2);
    i  	        = x_e{k}(3);
    p_sum_i     = x_e{k}(4);
    p_delta_i   = x_e{k}(5);
    v_lk        = x_e{k}(6);
    v_ref       = x_e{k}(7);
    w           = x_e{k}(8);
    theta       = x_e{k}(9);

    % Get inputs
    v_d         = u_e{k}(1);
    v_q         = u_e{k}(2);
    v           = u_e{k}(3);

    % Obtain small signal linearised model
    A = zeros(9,9);
    B = zeros(9,3);
    C = zeros(5,9);
    D = zeros(5,3);
    % id
    A(1,1) = -Rac/Lac;
    A(1,2) = W0;
    A(1,8) = i_q;
    B(1,1) = 1/Lac;
    % iq
    A(2,1) = -W0;
    A(2,2) = -Rac/Lac;
    A(2,8) = -i_d;
    B(2,2) = 1/Lac;
    % i
    A(3,3) = -Rdc/Ldc;
    A(3,7) = -1/Ldc;
    B(3,3) = 1/Ldc;
    % psumi
    A(4,8) = -beta/2/pi*ki_sum;
    B(4,3) = ki_sum;
    % pdiffi
    A(5,6) = ki_lk;
    % vlk
    A(6,1) = v_d/C_lk/v_lk;
    A(6,2) = v_q/C_lk/v_lk;
    A(6,3) = v/C_lk/v_lk;
    A(6,6) = -(i*v+v_d*i_d+v_q+i_q)/C_lk/(v_lk^2);
    B(6,1) = i_d/C_lk/v_lk;
    B(6,2) = i_q/C_lk/v_lk;
    B(6,3) = i/C_lk/v_lk;
    % vref
    A(7,3) = D_dc*v;
    A(7,4) = -wa*D_dc;
    A(7,5) = wa*D_dc;
    A(7,6) = wa*D_dc*kp_lk;
    A(7,7) = -wa;
    A(7,8) = D_dc*wa*kp_sum*beta/2/pi;
    B(7,3) = -wa*D_dc*kp_sum + D_dc*i;
    % w
    A(8,1) = D_ac*wa*v_d;
    A(8,2) = D_ac*wa*v_q;
    A(8,4) = D_ac*wa;
    A(8,5) = D_ac*wa;
    A(8,6) = D_ac*wa*kp_lk;
    A(8,8) = -D_ac*wa*kp_sum*beta/2/pi-wa;
    B(8,1) = D_ac*wa*i_d;
    B(8,2) = D_ac*wa*i_q;
    B(8,3) = D_ac*wa*kp_sum;
    % theta
    A(9,8) = 1;

    % y = id iq i w theta
    C(1,1) = 1;
    C(2,2) = 1;
    C(3,3) = 1;
    C(4,8) = 1;
    C(5,9) = 1;

    theoreticalSS = ss(A,B,C,D);

end