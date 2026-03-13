% This function obtains the State Space Representation of Transfverter
function theoreticalSS = TheoreticalImpedanceTransfverter(x_e, u_e, ApparatusPara, ApparatusPowerFlow, k)
    %% Obtain Parameters
    VAC0        = ApparatusPowerFlow{k}(3);
    V0          = ApparatusPowerFlow{k}(8);


    Rac     = ApparatusPara{k}(1);
    Lac     = ApparatusPara{k}(2);
    Rdc     = ApparatusPara{k}(3);
    Ldc     = ApparatusPara{k}(4);
    kp_sum  = ApparatusPara{k}(5);
    ki_sum  = ApparatusPara{k}(6);
    kp_lk   = ApparatusPara{k}(7);
    ki_lk   = ApparatusPara{k}(8);
    D_dc    = ApparatusPara{k}(9);
    D_ac    = ApparatusPara{k}(10);
    VLK0    = ApparatusPara{k}(11);
    W0      = ApparatusPara{k}(12);
    V0      = ApparatusPara{k}(13);
    wa      = ApparatusPara{k}(14);
    C_lk    = ApparatusPara{k}(15);
    kp_v_dq = ApparatusPara{k}(16);
    ki_v_dq = ApparatusPara{k}(17);
    kp_i_dq = ApparatusPara{k}(18);
    ki_i_dq = ApparatusPara{k}(19);
    kp_v    = ApparatusPara{k}(20);
    ki_v    = ApparatusPara{k}(21);
    kp_i    = ApparatusPara{k}(22);
    ki_i    = ApparatusPara{k}(23);
    Rov     = ApparatusPara{k}(24);
    Xov     = ApparatusPara{k}(25);
    
    beta        = D_dc/D_ac;

	% Get states
    i_d   	    = x_e{k}(1);
    i_q   	    = x_e{k}(2);
    i  	        = x_e{k}(3);
    i_d_i       = x_e{k}(4);
    i_q_i       = x_e{k}(5);
    v_d_i       = x_e{k}(6);
    v_q_i       = x_e{k}(7);
    i_i         = x_e{k}(8);
    v_i         = x_e{k}(9);
    p_sum_i     = x_e{k}(10);
    p_delta_i   = x_e{k}(11);
    v_lk        = x_e{k}(12);
    v_r         = x_e{k}(13);
    w           = x_e{k}(14);
    theta       = x_e{k}(15);
            
    % Get inputs
    v_d         = u_e{k}(1);
    v_q         = u_e{k}(2);
    v           = u_e{k}(3);

    % Object
    % v_d_r = obj.v_d_r;
    % v_q_r = obj.v_q_r;

    % Obtain small signal linearised model
    A = zeros(15,15);
    B = zeros(15,3);
    C = zeros(5,15);
    D = zeros(5,3);
    % id
    A(1,1) = -(Rac+kp_i_dq+Rov*kp_i_dq*kp_v_dq)/Lac;
    A(1,2) = W0+(kp_i_dq*kp_v_dq*Xov)/Lac;
    A(1,4) = -1/Lac;
    A(1,6) = -kp_i_dq/Lac;
    A(1,14) = i_q;
    B(1,1) = (1+kp_v_dq*kp_i_dq)/Lac;
    % iq
    A(2,1) = -W0-(kp_i_dq*kp_v_dq*Xov)/Lac;
    A(2,2) = -(Rac+kp_i_dq+Rov*kp_i_dq*kp_v_dq)/Lac;
    A(2,5) = -1/Lac;
    A(2,7) = -kp_i_dq/Lac;
    A(2,14)= -i_d;
    B(2,2) = (1+kp_v_dq*kp_i_dq)/Lac;
    % i
    A(3,3) = -(Rdc+kp_i)/Ldc;
    A(3,8) = -1/Ldc;
    A(3,9) = -kp_i/Ldc;
    A(3,13)= -kp_i*kp_v/Ldc;
    B(3,3) = (1+kp_i*kp_v)/Ldc;
    % idi
    A(4,1) = Rov*kp_v_dq*ki_i_dq + ki_i_dq;
    A(4,2) = -Xov*kp_v_dq*ki_i_dq;
    A(4,6) = ki_i_dq;  
    B(4,1) = -kp_v_dq*ki_i_dq; 
    % iqi
    A(5,1) = Xov*kp_v_dq*ki_i_dq;
    A(5,2) = Rov*kp_v_dq*ki_i_dq + ki_i_dq; 
    A(5,7) = ki_i_dq; 
    B(5,2) = -kp_v_dq*ki_i_dq; 
    % vdi
    A(6,1) = Rov*ki_v_dq;
    A(6,2) = -Xov*ki_v_dq;
    B(6,1) = -ki_v_dq;
    % vqi
    A(7,1) = Xov*ki_v_dq;
    A(7,2) = Rov*ki_v_dq;
    B(7,2) = -ki_v_dq;
    % ii
    A(8,3) = ki_i; 
    A(8,9) = ki_i;
    A(8,13)= ki_i*kp_v; 
    B(8,3) = -ki_i*kp_v; 
    % vi
    A(9,13)= ki_v;
    B(9,3) = -ki_v;
    % psumi
    A(10,14) = -beta/2/pi*ki_sum;
    B(10,3) = ki_sum;
    % pdiffi
    A(11,12) = ki_lk;
    % vlk
    A(12,1) = v_d/C_lk/v_lk;
    A(12,2) = v_q/C_lk/v_lk;
    A(12,3) = v/C_lk/v_lk;
    A(12,12) = -(i*v+v_d*i_d+v_q+i_q)/C_lk/(v_lk^2);
    B(12,1) = i_d/C_lk/v_lk;
    B(12,2) = i_q/C_lk/v_lk;
    B(12,3) = i/C_lk/v_lk;
    % vref
    A(13,3) = D_dc*v*wa; 
    A(13,10) = -wa*D_dc;
    A(13,11) = wa*D_dc;
    A(13,12) = wa*D_dc*kp_lk;
    A(13,13) = -wa;
    A(13,14) = D_dc*wa*kp_sum*beta/2/pi;
    B(13,3) = wa*D_dc*(i-kp_sum);
    % w
    A(14,1) = D_ac*wa*v_d;
    A(14,2) = D_ac*wa*v_q;
    A(14,10) = D_ac*wa;
    A(14,11) = D_ac*wa;
    A(14,12) = D_ac*wa*kp_lk;
    A(14,14) = -D_ac*wa*kp_sum*beta/2/pi-wa;
    B(14,1) = D_ac*wa*i_d;
    B(14,2) = D_ac*wa*i_q;
    B(14,3) = D_ac*wa*kp_sum;
    % theta
    A(15,14) = 1;

    % y = id iq i w theta
    C(1,1) = 1;
    C(2,2) = 1;
    C(3,3) = 1;
    C(4,14) = 1;
    C(5,15) = 1;

    theoreticalSS = ss(A,B,C,D);

end