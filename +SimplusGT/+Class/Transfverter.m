% This class defines the model of a pair of back-to-back dc-dc and dc-ac
% converter buffered by an interlink capacitor

% Author(s): George Zhang

%% Notes
%
% The model is in 
% ac-side: load convention, admittance form.
% dc-side: load convention, admittance form.

%% Class
classdef Transfverter < SimplusGT.Class.ModelAdvance
    
    % For temporary use
    properties(Access = protected)
        v_d_r;
        v_q_r;
    end

  	methods
        % Constructor
        function obj = Transfverter(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods(Static)
        
        % The dimensions of x, u, y must be consistent in following three
        % functions: SignalList, Equilibrium, and StateSpaceEqu.
        function [State,Input,Output] = SignalList(obj)
        	State  = {'i_d','i_q','i','i_d_i','i_q_i','v_d_i','v_q_i','i_i','v_i','p_sum_i', ...        % x, states
                      'p_delta_i','v_lk','v_r','w','theta'}; 	        
            Input  = {'v_d','v_q','v'};        	            % u, inputs
            Output = {'i_d','i_q','i','w','theta','v_lk','i_lk','p_dc_r','p_ac_r','dacpe','dacpe2'};         % y, outputs
        end
        
        % Calculate the equilibrium
        % The equilibrium is determined by the power flow data and apparatus's
        % own paramters.This function will be called once, at the
        % beginning of simulation.
        function [x_e,u_e,xi] = Equilibrium(obj)
            % Get the power PowerFlow values
            % The transfverter has two sets of power flow results
            % because it is connected to two buses: the first one is ac,
            % and the second one is dc.
            P_ac    = obj.PowerFlow(1);
            Q_ac    = obj.PowerFlow(2);
            Vg_ac   = obj.PowerFlow(3);
            xi      = obj.PowerFlow(4);
            w       = obj.PowerFlow(5);
            
            P_dc    = obj.PowerFlow(6);
            Vg_dc   = obj.PowerFlow(8);

            
            
          	% Get parameters
            Rac     = obj.Para(1);
            Lac     = obj.Para(2);
            Rdc     = obj.Para(3);
            Ldc     = obj.Para(4);
            kp_sum  = obj.Para(5);
            ki_sum  = obj.Para(6);
            kp_lk   = obj.Para(7);
            ki_lk   = obj.Para(8);
            D_dc    = obj.Para(9);
            D_ac    = obj.Para(10);
            VLK0    = obj.Para(11);
            W0      = obj.Para(12);
            V0      = obj.Para(13);
            wa      = obj.Para(14);
            C_lk    = obj.Para(15);
            kp_v_dq = obj.Para(16);
            ki_v_dq = obj.Para(17);
            kp_i_dq = obj.Para(18);
            ki_i_dq = obj.Para(19);
            kp_v    = obj.Para(20);
            ki_v    = obj.Para(21);
            kp_i    = obj.Para(22);
            ki_i    = obj.Para(23);
            Rov     = obj.Para(24);
            Xov     = obj.Para(25);
            
            beta = D_dc/D_ac;           
            
            % Calculate equilibrium
            v = Vg_dc;
            i = P_dc/v;
            e = v - i*Rdc;
            
            w = (v - V0)*2*pi/beta + W0;

            v_d = Vg_ac;
            v_q = 0;
            i_d = P_ac/v_d;
            i_q = -Q_ac/v_d;
            v_dq = v_d + 1i*v_q;
            i_dq = i_d + 1i*i_q;
            e_dq = v_dq - i_dq*(Rac + 1i*w*Lac);

            %v_r = e;
            i_i = e;
            v_i = i;
            v_r = v;

            i_d_i = real(e_dq);
            i_q_i = imag(e_dq);
            v_d_i = -i_d;
            v_q_i = -i_q;

            v_dq_r = v_dq - i_dq*(Rov + 1i*Xov);
            v_d_r = real(v_dq_r);
            v_q_r = imag(v_dq_r);
            obj.v_d_r = v_d_r;
            obj.v_q_r = v_q_r;
            
            p_dc_r = (v_r-V0)/D_dc + P_dc;
            p_ac_r = P_ac + (w - W0)/D_ac;
  
            p_sum_r = (p_ac_r - p_dc_r)/2;
            p_delta_r = (p_ac_r + p_dc_r)/2;
            
            p_sum_i = p_sum_r;
            p_delta_i = p_delta_r;
            
            v_lk = VLK0;
            
            theta = xi;

            % Set equilibrium
            x_e = [i_d; i_q; i; i_d_i; i_q_i; v_d_i; v_q_i; i_i; v_i; p_sum_i; p_delta_i; v_lk; v_r; w; theta];
            u_e = [v_d; v_q; v];
            xi  = xi;
        end
        
    	% State space model
        %
        % This function will be called at each step, i.e., Ts, during the
        % whole precedure of the discrete simulation.
        %
        % The state space model is a large-signal model rather than
        % a small-signal model. The linearized model will be calculated by
        % functions in the parent class and the linearization point (i.e.
        % equilibrium) is calculated above.
        function [Output] = StateSpaceEqu(obj,x,u,CallFlag)
            % P_ac    = obj.PowerFlow(1);
            % Vg_ac   = obj.PowerFlow(3);
            % Vg_dc   = obj.PowerFlow(8);
            VAC0   = obj.PowerFlow(3);
            V0     = obj.PowerFlow(8);

          	% Get parameter

            Rac     = obj.Para(1);
            Lac     = obj.Para(2);
            Rdc     = obj.Para(3);
            Ldc     = obj.Para(4);
            kp_sum  = .6;%obj.Para(5);
            ki_sum  = 21;%obj.Para(6);
            kp_lk   = 0;%obj.Para(7);
            ki_lk   = 0;%obj.Para(8);
            D_dc    = obj.Para(9);
            D_ac    = obj.Para(10);
            VLK0    = obj.Para(11);
            W0      = obj.Para(12);
            V0      = obj.Para(13);
            wa      = obj.Para(14);
            C_lk    = obj.Para(15);
            kp_v_dq = obj.Para(16);
            ki_v_dq = obj.Para(17);
            kp_i_dq = obj.Para(18);
            ki_i_dq = obj.Para(19);
            wi=2*pi*1000;
            wv = 2*pi*50;
            kp_i_dq = Lac*wi;
            ki_i_dq = Lac*wi^2/4;
            k=1; 
            kp_v_dq    = wv/wi/k;              % v, P
            ki_v_dq    = wv/k; 
            % kp_v_dq = 1/(16*wi*Lac);
            % ki_v_dq = 1/(4*Lac);

            kp_v    = obj.Para(20);
            ki_v    = obj.Para(21);
            kp_i    = obj.Para(22);
            ki_i    = obj.Para(23);
            Rov     = obj.Para(24);
            Xov     = obj.Para(25);

            %V0 = obj.Para(12);
            %VAC0 = obj.Para(13);
            
            beta = D_dc/D_ac;

        	% Get states
            i_d   	    = x(1);
            i_q   	    = x(2);
            i  	        = x(3);
            i_d_i       = x(4);
            i_q_i       = x(5);
            v_d_i       = x(6);
            v_q_i       = x(7);
            i_i         = x(8);
            v_i         = x(9);
            p_sum_i     = x(10);
            p_delta_i   = x(11);
            v_lk        = x(12);
            v_r         = x(13);
            w           = x(14);
            theta       = x(15);
            
            v_d_r = obj.v_d_r;
            v_q_r = obj.v_q_r;
            % Get inputs
            v_d    = u(1);
            v_q    = u(2);
            v      = u(3);
            
            % State space equations
          	% dx/dt = f(x,u)
            % y     = g(x,u)

            % Power Measurement
            p_dc =  (v*i)*(-1);
            p_ac =  (v_d*i_d + v_q*i_q)*(-1);

            % Interlink Control
            p_bal           = (v - V0) - beta * (w - W0)/(W0);
            p_sum_r         = p_bal * kp_sum + p_sum_i;
            dp_sum_i        = p_bal * ki_sum;
            p_delta_r       = (v_lk - VLK0) * kp_lk + p_delta_i;
            dp_delta_i      = (v_lk - VLK0) * ki_lk;
            % p_delta_r=0;
            p_dc_r          = p_delta_r - p_sum_r;
            p_ac_r          = p_delta_r + p_sum_r;
            p_dc_r = 0.5;
            p_ac_r = -0.5;
            % if obj.Timer>2
            %     p_dc_r = -0.5;
            %     p_ac_r = 0.5;
            % end

            % AC Droop Control
            p_ac_r = .5;
            if obj.Timer>2
                % p_dc_r = -0.5;
                p_ac_r = 1;
            end
            D_ac =0.01;
            dacpe = D_ac*(p_ac_r -p_ac);
            dacpe2 = dacpe+1;
            dw              = ((D_ac * (p_ac_r - p_ac)+1)*W0 - w)*wa;
            % DC Droop Control
            dv_r            = (D_dc * (p_dc_r - p_dc) + V0 - v_r)*wa;
            
            % AC voltage control
            error_v_d = v_d_r - v_d - (i_d*Rov-i_q*Xov)*(-1);
          	error_v_q = v_q_r - v_q - (i_q*Rov+i_d*Xov)*(-1);
            i_d_r = -(error_v_d*kp_v_dq + v_d_i);
            i_q_r = -(error_v_q*kp_v_dq + v_q_i);
            dv_d_i = error_v_d*ki_v_dq;
            dv_q_i = error_v_q*ki_v_dq;

            % AC current control
            error_i_d = i_d_r-i_d;
            error_i_q = i_q_r-i_q;
            e_d = -error_i_d*kp_i_dq + i_d_i;
            e_q = -error_i_q*kp_i_dq + i_q_i;
            di_d_i = -error_i_d*ki_i_dq;
            di_q_i = -error_i_q*ki_i_dq;

            % DC voltage control
            error_v = v_r - v;
            i_r = -(error_v*kp_v + v_i);
            dv_i = error_v*ki_v;

            % DC current control
            error_i = i_r-i;
            e_dc = -error_i*kp_i + i_i;
            di_i = -error_i*ki_i;
            
            % Link Dynamics [Potential Inaccuracy due to incorrect power
            % calc]
            pe_dc =  (e_dc*i)*(-1);
            pe_ac =  (e_d*i_d + e_q*i_q)*(-1);
            i_lk_dc = pe_dc/v_lk;
            i_lk_ac = pe_ac/v_lk;
            i_lk = - i_lk_dc - i_lk_ac;
            dv_lk = i_lk/C_lk;
            
            % DC-AC Sources
            % e_d = VAC0;
            % e_q = 0;
            % w=2*pi*60;
            dtheta = w;
            % e_dc = v_r;

            % AC filter inductor
          	di_d = (v_d - Rac*i_d + w*Lac*i_q - e_d)/Lac;
            di_q = (v_q - Rac*i_q - w*Lac*i_d - e_q)/Lac;

            % DC filter inductor
          	di = (v - Rdc*i - e_dc)/Ldc;

            if CallFlag == 1
                % ### Call state equation: dx/dt = f(x,u)
                f_xu = [di_d; di_q; di; di_d_i; di_q_i; dv_d_i; dv_q_i; di_i; dv_i; dp_sum_i; dp_delta_i; dv_lk; dv_r; dw; dtheta];
                Output = f_xu;
            elseif CallFlag == 2
                % ### Call output equation: y = g(x,u)
                g_xu = [i_d; i_q; i; w; theta; v_lk; i_lk; p_dc_r; p_ac_r;dacpe;dacpe2];
                Output = g_xu;
            end
        end
        
    end
end
