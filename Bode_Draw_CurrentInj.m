clear FS_Final
FS_Final.freq = out.FS_Freq_point(1:2:end); % Test Frequency Points
N = length(out.FS_Freq_point);      
Zsys = zeros(2,2,N);           % 2×2×N
ZA = zeros(2,2,N);  
ZG = zeros(2,2,N); 
for k = 1:N
    Zsys(:,:,k) = out.FS_Result(2*k-1:2*k, 1:2);      % kth frequency block
    ZA(:,:,k) = out.FS_Result(2*k-1:2*k, 3:4);      % kth frequency block
    ZG(:,:,k) = out.FS_Result(2*k-1:2*k, 5:6);      % kth frequency block
end
w_r = out.FS_Freq_point*2*pi;


%%    

YcellSs{2}  = GsysSs(PortBusI{2},PortBusV{2});
Y_ss_ref = YcellSs{2}; 
Yref_fr_from_SS = freqresp(Y_ss_ref, w_r);
xi = PowerFlow{1,2}(4);
Txi = [cos(xi),-sin(xi);
       sin(xi), cos(xi)];
Zref_fr_from_SS = pageinv(Yref_fr_from_SS(1:2,1:2,:));
Zsys2 = (Txi) .* Zsys .* Txi.';
figure(101); clf;
freqresp_bode_cpr(Zsys, Zref_fr_from_SS, w_r, 101, 'x', ...
    'LineWidth', 1, 'XLim',[2 400], ...  % applies to both, unless overridden below
    'ScanArgs', {'LineWidth', 1}, ...
    'RefArgs',  {'LineWidth', 1.2});
freqresp_bode_cpr(Zsys2, [], w_r, 101, 'x', ...
    'LineWidth', 1, 'XLim',[2 400], ...  % applies to both, unless overridden below
    'ScanArgs', {'LineWidth', 1}, ...
    'RefArgs',  {'LineWidth', 1.2});

%%

YA_ss_ref_global_steady = GmDssCell{1,2};
YA_ss_ref_local_swing= Gm2{1,2};
YA_ss_ref_local_steady = Gm3{1,2};
YAref_fr_from_SS_local_sw = freqresp(YA_ss_ref_local_swing, w_r);
YAref_fr_from_SS_local_st = freqresp(YA_ss_ref_local_steady, w_r);
YAref_fr_from_SS_global_st = freqresp(YA_ss_ref_global_steady, w_r);
% Transformation matrix
xi = PowerFlow{1,2}(4);
Txi = [cos(xi),-sin(xi);
       sin(xi), cos(xi)]
ZAref_fr_from_SS_local_sw = pageinv(YAref_fr_from_SS_local_sw(1:2,1:2,:));
ZAref_fr_from_SS_local_st = pageinv(YAref_fr_from_SS_local_st(1:2,1:2,:));
ZAref_fr_from_SS_global_st = pageinv(YAref_fr_from_SS_global_st(1:2,1:2,:));
% YA2 = (Txi).' .* ZA .* Txi;
figure(102); clf;
freqresp_bode_cpr(-ZA, ZAref_fr_from_SS_local_st, w_r, 102, 'x', ...
    'LineWidth', 1, 'XLim',[2 400], ...
    'LegendStrings', {'Frequency Scan','Local Swing'},...% applies to both, unless overridden below
    'ScanArgs', {'LineWidth', 1}, ...
    'RefArgs',  {'LineWidth', 1.2});
% freqresp_bode_cpr([], ZAref_fr_from_SS_local_st, w_r, 102, 'x', ...
%     'LineWidth', 1, 'XLim',[2 400], ...  % applies to both, unless overridden below
%     'LegendStrings', {'','Local Steady'},...
%     'ScanArgs', {'LineWidth', 1}, ...
%     'RefArgs',  {'LineWidth', 1.2});
% freqresp_bode_cpr([], ZAref_fr_from_SS_global_st, w_r, 102, 'x', ...
%     'LineWidth', 1, 'XLim',[2 400], ...  % applies to both, unless overridden below
%     'LegendStrings', {'','Global Steady'},...
%     'ScanArgs', {'LineWidth', 1}, ...
%     'RefArgs',  {'LineWidth', 1.2});


%%
YGref_fr_from_SS = 1/Yref_fr_from_SS-YAref_fr_from_SS(1:2,1:2,:);%freqresp(YG_ss_ref, w_r);
figure(103)
freqresp_bode_cpr(YG, YGref_fr_from_SS, w_r, 103, 'x', ...
    'LineWidth', 1, 'XLim',[2 400], ...  % applies to both, unless overridden below
    'ScanArgs', {'LineWidth', 1}, ...
    'RefArgs',  {'LineWidth', 1.2});