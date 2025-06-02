% Gauss - Seidel power flow analysis

% Author(s): Yitong Li, Yunjie Gu

function [PowerFlow,Ybus,V,I,Ang0,P,Q,Vm]=PowerFlowGSHybrid(ListBus,ListLine,w0,ICBus,ICLinkedBus)

Ybus = SimplusGT.PowerFlow.YbusCalc(ListLine);      % Get nodal admittance matrix

ListNumber = ListBus(:,1);      % Bus number
N_Bus = max(ListNumber);        % Total number of buses
ListType = ListBus(:,2);        % Ac bus type: 1-Slack, 2-PV,  3-PQ
                                % Dc bus type: 1-Slack, 2-N/A, 3-P

IndexSlack = find(ListType == 1);      % Index of slack bus

V0   = ListBus(:,3);         % Initial bus voltages.
th0  = ListBus(:,4);         % Initial bus voltage angles.

PGi = ListBus(:,5);         % Active power injected into the buses, source convention
QGi = ListBus(:,6);         % Reactive power injected into the buses. source convention
PLi = ListBus(:,7);         % Active power drawn from the buses, load convention
QLi = ListBus(:,8);         % Reactive power drawn from the buses, load convention

Qmin = ListBus(:,9);        % Minimum Reactive Power Limit
Qmax = ListBus(:,10);       % Maximum Reactive Power Limit

P = PGi - PLi;  	% Net actove power at buses.
Q = QGi - QLi;      % Net reactive power at buses.

V = SimplusGT.pol2rect(V0,th0);    	% Convert voltages from polar form to rectangular form
% V = V0;
Vprev = V;

tolerance = 1;           	% Initialize tolerence
iteration = 0;              % Initialize interaction count

tolerance_max  = 1e-8;
iteration_max  = 1e5;

% Set order of iteration, starting with DC area and slack bus last.
busorder = sortrows(ListBus,[12,2],{'descend','descend'})
P_t = zeros(N_Bus,1)
while ((tolerance>tolerance_max) && (iteration<=iteration_max))
    
    for j = 1:N_Bus
        i = busorder(j,1); % Comment out for normal PF
        if ListType(i) ~= 1         % Calculate V for non slack bus
            
            sum_yv = 0;     
            for k = 1:N_Bus
                if i ~= k
                    sum_yv = sum_yv + Ybus(i,k)* V(k);  % Vk * Yik
                end
            end
        
            if ListType(i) == 2   	% Calculate Qi for PV bus
                Q(i) = -imag(conj(V(i))*(sum_yv + Ybus(i,i)*V(i)));     % Equation (6.91) in Kunder's book
                if (Q(i) > Qmax(i)) || (Q(i) < Qmin(i))  % Checking for Qi violation
                    if Q(i) < Qmin(i)
                        Q(i) = Qmin(i); % Set Qi to lower limit
                    else          
                        Q(i) = Qmax(i); % Set Qi to upper limit
                    end
                    ListType(i) = 3;        % If violated, change bus type from PV to PQ
                end
            end
        
            V(i) = (1/Ybus(i,i))*((P(i)-1j*Q(i))/conj(V(i)) - sum_yv);  % Compute bus boltage
                                                                        % Equation (6.90) in Kundur's book
            
            if ListType(i) == 2 
                V(i) = SimplusGT.pol2rect(abs(Vprev(i)), angle(V(i)));  % For PV bus, voltage magnitude remains same, but angle changes.
            end
        
        end
            if (ListType(i) == 1 && ICBus(i) == 1) % For DC slack bus on Interlinking Converter
                % calculate power
                I_t(i) = Ybus(i,:)*V
                S_t(i) = V(i).*conj(I_t(i))
                % Set AC bus power to 
                %P = PGi - PLi; 
                P_t(i) = -real(S_t(i))
                P(ICLinkedBus(i)) = P(ICLinkedBus(i)) + P_t(i)
                fprintf("slack DC IC")
            end
        
    end
    
    iteration = iteration + 1;         	% Increment iteration count.
    if iteration == iteration_max  	% Check the convergence of power flow.
        error(['Error: The PowerFlow does not converge or needs more steps to converge!']);
    end
    
    I = Ybus*V;
    % S = I.*conj(V);
    S = V.*conj(I);
    N = length(V);
    
    tolerV = max(abs(abs(V) - abs(Vprev)));         % Calculate V tolerance.
    tolerP = abs(real(S(1:N)) - P(1:N));            % Calculate P tolerance
    tolerP(IndexSlack) = 0;                         % The P tolerance at slack bus should be ignored
    tolerP = max(tolerP);
%  	tolerQ = max(abs(imag(S(2:N)) + Q(2:N)));     % Calculate Q tolerance, exclude the slack terminal
    tolerQ = 0;
    
    % We use tolerV only here to check the total tolerance
    tolerance  = max([tolerV,tolerP,tolerQ]);       % Calculate total tolerance
    Vprev = V;  % Vprev is required for next iteration,  V(i) = pol2rect(abs(Vprev(i)), angle(V(i)));
    
end             % End of while loop / Iteration

Ang0 = angle(V);  % Final Bus Voltage Angles in rad.
Vm = abs(V);    % Final Bus Voltage Amplitude.
S = V.*conj(I); % Final Appearant Power, Generator Convention.
P = real(S);    % Final Active Power, Generator Convention.
Q = imag(S);    % Final Reactive Power, Generator Convention.

for i = 1:N_Bus
    % The negative signs make P and Q in load convention
    PowerFlow{i} = [-P(i) -Q(i) Vm(i) Ang0(i) w0];
end

end



