%% Readme
%
% Default 4-bus power system user data is saved in "UserData.xlsm" and
% "UserData.json". More examples can be found in "Examples" folder.
%
% More manuals are available in the "Documentations" folder.

%% Clear matlab
clear all; clc; close all; 

%% User data
UserDataName = 'UserData';      % Default 4-bus system

% Example power systems in "Examples" folder:
%
% Ac power system examples:
% UserDataName = 'SgInfiniteBus';               % Single synchronous generator and infinite bus
UserDataName = 'GflInverterInfiniteBus';   	% Single grid-following inverter and infinite bus
% UserDataName = 'GflInverterInfiniteBusNoLine';   	% Single grid-following inverter and infinite bus
% UserDataName = 'GfmInverterInfiniteBus';   	% Single grid-forming inverter and infinite bus
% UserDataName = 'BessInfiniteBus';             % Single battery energy storage system and infinite bus
% UserDataName = 'PVInfiniteBus';               % Single Photovoltaic and infinite bus
% UserDataName = 'IEEE_14Bus';
% UserDataName = 'IEEE_14Bus_GFM';
%UserDataName = 'IEEE_14Bus_Cyprus_original';
% UserDataName = 'IEEE_30Bus';
% UserDataName = 'IEEE_57Bus';
% UserDataName = 'AU14Gen_59Bus';
% UserDataName = 'NETS_NYPS_68Bus';
% UserDataName = 'BESS_Plant_10Bus';            % A 10-unit battery energy storage plant
% UserDataName = 'PV_Plant_10Bus';              % A 10-unit photovoltaic plant
% UserDataName = 'PV_BESS_Hybrid_Plant_10Bus';  % A 10-unit photovoltaic and energy storage hybrid plant
%
% Dc power system examples:
% UserDataName = 'GfdBuckInfiniteBus';         % Single grid-feeding buck converter and infinite bus
% UserDataName = 'TwoBusGfdBuck';              % Two buck converters
% UserDataName = 'FourBusGfdBuck_baseline';      % Three buck converters in 4-bus network
% UserDataName = '2IBR_4_bus_case3';
% UserDataName = 'FourBusGfdBuck_detuned1';     % 2 converters detuned 400 400
% UserDataName = 'FourBusGfdBuck_detuned2';     % 1 converter detuned 555 356
% UserDataName = 'FourBusGfdBuck_detuned3';     % 600 800 900


% Hybrid ac-dc power system examples:
% UserDataName = 'Hybrid_4Bus';             % A 4-bus hybrid ac-dc system
% UserDataName = 'Hybrid_Single_Interlinking_Dual_Infinite_Bus';             % A 4-bus hybrid ac-dc system
% UserDataName = 'Hybrid_5Bus';             % A 4-bus hybrid ac-dc system
% UserDataName = 'Hybrid_28Bus';
% UserDataName = 'HVDC_Infbus_4Bus';        % HVDC system connected to inf buses
% UserDataName = 'HVDC_SG_4Bus';            % HVDC system connected to equivalent SG buses
% UserDataName = 'MTDC_Infbus_4Bus';        % MTDC system connected to inf buses

%% Change the current folder of matlab
cd(fileparts(mfilename('fullpath')));

%% Set user data type
% If user data is in excel format, please set 1. If it is in json format,
% please set 0.
UserDataType = 1;

%% Run toolbox
SimplusGT.Toolbox.Main();  
%%
SimplusGT.Modal.IMRCal;
%% Matlab app
if 0; ModalAnalysisAPP; end      % Modal analysis

%%
% 
% Gmss = dss2ss(GmDssCell{2});
% Gmsym= SimplusGT.ss2sym(Gmss);
%     OmegaP = logspace(-1,4,500)*2*pi;
% figure(1);
% clf;
% subplot(2,2,1);
% x = SimplusGT.bode_c(Gmsym(1,1), 1j*OmegaP, 'PhaseOn', 1);
% title('Element G(1,1)');
% grid on;
% hold on
% 
% % % --- Plot for G(1,2) ---
% % subplot(2, 2, 2); % Select the 2nd subplot
% % SimplusGT.bode_c(Gmsym(1,1), 1j*OmegaP, 'PhaseOn', 1);
% % title('Element G(1,2)');
% % grid on;
% % hold on
% % % --- Plot for G(2,1) ---
% % subplot(2, 2, 3); % Select the 3rd subplot
% % SimplusGT.bode_c(Gmsym(1,1), 1j*OmegaP, 'PhaseOn', 1);
% % title('Element G(2,1)');
% % grid on;
% % hold on
% % 
% % % --- Plot for G(2,2) ---
% % subplot(2, 2, 4); % Select the 4th subplot
% % SimplusGT.bode_c(Gmsym(1,1), 1j*OmegaP, 'PhaseOn', 1);
% % title('Element G(2,2)');
% % grid on;
% %%
%            	YcellSs{k}  = GsysSs(PortBusI{k},PortBusV{k});
%             YcellSym{k} = SimplusGT.ss2sym(YcellSs{k});
%             YcellSsCplx{k} = T*YcellSs{k}*T^(-1);
%             YcellSymCplx{k} = SimplusGT.ss2sym(YcellSsCplx{k});
% 
%             figure(FigN);
%             SimplusGT.bode_c(YcellSym{k}(1,1),1j*OmegaP,'PhaseOn',1); 
%             figure(FigN+1);
%             SimplusGT.bode_c(YcellSymCplx{k}(1,1),1j*OmegaPN,'PhaseOn',1); 

