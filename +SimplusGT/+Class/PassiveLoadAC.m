% This class defines the model of a three phase RLC branch.
% The model uses load convention, admittance form.
% Author(s): George Zhang

classdef PassiveLoadAC < SimplusGT.Class.ModelAdvance

    methods
        % Constructor
        function obj = PassiveLoadAC(varargin)
            % Support name-value pair arguments
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods(Static)
        function [State,Input,Output] = SignalList(obj)
            State  = {'i_d','i_q'};
        	Input  = {'v_d','v_q'};
            Output = {'i_d','i_q'};
        end

        function [x_e,u_e,xi] = Equilibrium(obj)      
            % Get the power PowerFlow values
            P 	= obj.PowerFlow(1);
            Q	= obj.PowerFlow(2);
            V	= obj.PowerFlow(3);
            xi	= obj.PowerFlow(4);
            w   = obj.PowerFlow(5);
            
            % Get Parameters
            R = obj.Para(1);
            L = obj.Para(2);
            %C = obj.Para(3);
            
            % Calculate equilibirum
            % Grid voltage defines the frame orientation (v_q = 0)
            v_d = V;
            v_q = 0;
            % Equilibrium current under assumption v_q = 0
            i_d = R/(R^2 + (w*L)^2)*v_d;
            i_q = -w*L/(R^2 + (w*L)^2)*v_d;

            % Set equilibrium
            x_e = [i_d; i_q];
            u_e = [v_d; v_q];
            xi  = [xi];
        end

        function [Output] = StateSpaceEqu(obj,x,u,CallFlag)

            % Get Parameters
            R = obj.Para(1);
            L = obj.Para(2);
            w   = obj.PowerFlow(5);
            %C = obj.Para(3);

            % Get states
          	i_d   = x(1);
         	i_q   = x(2);

            % Get inputs
        	v_d   = u(1);
            v_q   = u(2);

            % State space equations
          	% dx/dt = f(x,u)
            % y     = g(x,u)

            % AC RL Equation
          	di_d = (v_d - R*i_d + w*L*i_q)/L;
            di_q = (v_q - R*i_q - w*L*i_d)/L;
            
            if CallFlag == 1    
            % ### Call state equation: dx/dt = f(x,u)
                f_xu = [di_d; di_q];
                Output = f_xu;
            
            elseif CallFlag == 2
      	    % ### Call output equation: y = g(x,u)
                g_xu = [i_d; i_q];
                Output = g_xu;
            end
        end

    end
end