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
        	State  = {'i_d','i_q','i','p_sum_i', ...        % x, states
                      'p_delta_i','v_lk','v_ref','w_ref','w','theta'}; 	        
            Input  = {'v_d','v_q','v'};        	            % u, inputs
            Output = {'i_d','i_q','i','w','theta'};         % y, outputs
        end
        
        % Calculate the equilibrium
        % The equilibrium is determined by the power flow data and apparatus's
        % own paramters.This function will be called once, at the
        % beginning of simulation.
        function [x_e,u_e,xi] = Equilibrium(obj)
         	% Get the power PowerFlow values
            P 	= obj.PowerFlow(1);
            Q	= obj.PowerFlow(2);
            V	= obj.PowerFlow(3);
            xi	= obj.PowerFlow(4);
            w   = obj.PowerFlow(5);
            
            % Get parameters
            obj.Para(1);
            % if you would like to change the parameters at 2.0s. Taking xi as an example 
            if obj.Timer>2
                xi =6;
            end
            
            
            % Calculate equilibrium
            
            % Set equilibrium
            x_e = [];
            u_e = [];
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

            Rac = obj.Para(1);
            Lac = obj.Para(2);
            Rdc = obj.Para(3);
            Ldc = obj.Para(4);
            kp_sum = obj.Para(5);
            ki_sum = obj.Para(6);
            kp_lk = obj.Para(7);
            ki_lk = obj.Para(8);
            D_dc = obj.Para(9);
            D_ac = obj.Para(10);
            VLK0 = obj.Para(11);
            W0 = obj.Para(12);
            %V0 = obj.Para(12);
            %VAC0 = obj.Para(13);
            
            beta = D_dc/D_ac;

        	% Get states
            i_d   	    = x(1);
            i_q   	    = x(2);
            i  	        = x(3);
            p_sum_i     = x(4);
            p_delta_i   = x(5);
            v_lk        = x(6);
            v_ref       = x(7);
            w_ref  	    = x(8);
            w           = x(9);
            theta       = x(10);

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
            p_bal = (v - VDC0) - beta * (w - W0)/(2*pi);
            p_sum_ref = p_bal * kp_sum + p_sum_i;
            dp_sum_i = p_bal * ki_sum;
            p_delta_ref = (v_lk - VLK0) * kp_lk + p_delta_i;
            dp_delta_i = (v_lk - VLK0) * ki_lk;
            p_dc_ref = p_delta_ref - p_sum_ref;
            p_ac_ref = p_delta_ref + p_sum_ref;

            % AC Droop Control
            dw_ref = (D_ac * (p_ac_ref - p_ac) + W0 - w_ref)*wa;

            % DC Droop Control
            dv_ref = (D_dc * (p_dc_ref - p_dc) + V0 - v_ref)*wa;

            % Link Dynamics
            i_lk_dc = p_dc/v_lk;
            i_lk_ac = p_ac/v_lk;
            i_lk = - i_lk_dc - i_lk_ac;
            dv_lk = i_lk/C_lk;
            
            % DC-AC Sources
            e_d = VAC0;
            e_q = 0;
            w = w_ac_ref;
            dtheta = w;
            e_dc = v_dc_ref;

            % AC filter inductor
          	di_d = (v_d - Rac*i_d + w*Lac*i_q - e_d)/Lac;
            di_q = (v_q - Rac*i_q - w*Lac*i_d - e_q)/Lac;

            % DC filter inductor
          	di = (v - Rdc*i - e_dc)/Ldc;

            if CallFlag == 1
                % ### Call state equation: dx/dt = f(x,u)
                f_xu = [di_d; di_q; di; dp_sum_i; dp_delta_i; dv_lk; dv_ref; dw_ref; dw; dtheta];
                Output = f_xu;
            elseif CallFlag == 2
                % ### Call output equation: y = g(x,u)
                g_xu = [i_d; i_q; i; w; theta];
                Output = g_xu;
            end
        end
        
    end
end
