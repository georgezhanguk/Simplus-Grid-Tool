clear FS_Final
% If not automatically running, then results might be saved in out.FS____
% Run the following commented lines
FS_Freq_point = out.FS_Freq_point;
FS_Result = out.FS_Result;

FS_Final.freq = FS_Freq_point(1:2:end); % Test Frequency Points
N = length(FS_Freq_point);      
Ysys = zeros(2,2,N);           % 2×2×N
YA = zeros(2,2,N);  
YG = zeros(2,2,N); 
for k = 1:N
    Ysys(:,:,k) = FS_Result(2*k-1:2*k, 1:2);    % Ysys Results
    YA(:,:,k) = FS_Result(2*k-1:2*k, 3:4);      % YA Results
    YG(:,:,k) = FS_Result(2*k-1:2*k, 5:6);      % YG Results
end
w_r = FS_Freq_point*2*pi;
%% Ysys Bode Plot 
% Comparison can be made with theoretical SimplusGT values via below:
YcellSs{2}  = GsysSs(PortBusI{2},PortBusV{2}); % change 2 to apparatus no.
Y_ss_ref = YcellSs{2}; 
Yref_fr_from_SS = freqresp(Y_ss_ref, w_r);
% Ysys_g = pagemtimes(pagemtimes(Txi,Ysys),inv(Txi));
% If Yref_fr... is not needed then replace with empty array, []
figure(101); clf;
freqresp_bode(Ysys,  Yref_fr_from_SS, w_r, 101, 'XLim',[2 400],...
    'H1Args', {'x', 'Color', 'r','DisplayName','Frequency Scan'}, ...  % "H1" settings
    'H2Args', {'-', 'Color', 'b','DisplayName','Reference'});  % "H2" settings
% freqresp_bode(Ysys_g,  [], w_r, 101, 'XLim',[2 400],...
%     'H1Args', {'x', 'Color', 'g','DisplayName','Frequency Scan'}, ...  % "H1" settings
%     'H2Args', {'-', 'Color', 'b','DisplayName','Reference'});  % "H2" settings

%% YA Bode Plot
% Comparison can be made with theoretical SimplusGT values via below:
% Gm3 is obtained from an intermediate step in ApparatusModelCreate - it is
% the admittance in the local steady frame.

YA_ss_ref_global_steady = GmDssCell{1,2};
% YA_ss_ref_local_swing= Gm2{1,2};
YA_ss_ref_local_steady = Gm3{1,2};
YAref_fr_from_SS_local_st = freqresp(YA_ss_ref_local_steady, w_r);
YAref_fr_from_SS_global_st = freqresp(YA_ss_ref_global_steady, w_r);
xi = PowerFlowNew{1,2}(4);
Txi = [cos(xi),-sin(xi);
       sin(xi), cos(xi)];
YA_ls = pagemtimes(pagemtimes((Txi),YA),inv(Txi));
% If YAref_fr... is not needed then replace with empty array, []
figure(102); clf;
freqresp_bode(YA_ls, YAref_fr_from_SS_local_st, w_r, 102, 'XLim',[2 400], ...
    'H1Args', {'x', 'Color', 'r','DisplayName','Frequency Scan'}, ...  % "H1" settings
    'H2Args', {'-', 'Color', 'b','DisplayName','Reference'});  % "H2" settings
freqresp_bode(YA, YAref_fr_from_SS_global_st, w_r, 102, 'XLim',[2 400], ...
    'H1Args', {'x', 'Color', 'm','DisplayName','Frequency Scan GS'}, ...  % "H1" settings
    'H2Args', {'-', 'Color', 'c','DisplayName','Reference GS'});  % "H2" settings

%% YG Bode Plot
% YGref_fr_from_SS = 1/Yref_fr_from_SS-YAref_fr_from_SS(1:2,1:2,:);%freqresp(YG_ss_ref, w_r);
figure(103); clf;
freqresp_bode(YG, [], w_r, 103, 'XLim',[2 400], ...
    'H1Args', {'x', 'Color', 'r','DisplayName','Frequency Scan'}, ...  % "H1" settings
    'H2Args', {'-', 'Color', 'b','DisplayName','Reference'});  % "H2" settings