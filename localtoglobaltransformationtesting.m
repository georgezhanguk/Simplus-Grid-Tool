%% Global/ Local and 
%% SECTION 1: Frequency Response Admittance Spectrum
% Low frequency sweep: 2-10 Hz
w_r = linspace(1,2*pi*1000,1000);
YA_ss_ref_local_steady = Gm3{1,2}; % Comparison is made in the local steady frame
YA_ss_ref_local_swing= Gm2{1,2}; % Comparison is made in the local steady frame
YA_ss_ref_global_steady = Gm{1,2}; % Comparison is made in the local steady frame
YAref_fr_from_SS_local_sw = freqresp(YA_ss_ref_local_swing(1:2,1:2), w_r);
YAref_fr_from_SS_local_st = freqresp(YA_ss_ref_local_steady(1:2,1:2), w_r);
YAref_fr_from_SS_global_st = freqresp(YA_ss_ref_global_steady(1:2,1:2), w_r);
xi = PowerFlowNew{1,2}(4);
Txi = [cos(xi),-sin(xi);
       sin(xi), cos(xi)];
test_tf_fr = pagemtimes(pagemtimes(inv(Txi),YAref_fr_from_SS_global_st),(Txi));
%% GFL SMIB Original
figure(111); clf;
freqresp_bode(YAref_fr_from_SS_global_st,YAref_fr_from_SS_local_st, w_r, 111,'XLim',[1 1000], ...
    'H1Args', {'-', 'Color', 'r','DisplayName','Global Steady'},...
    'H2Args', {'-', 'Color', 'g','DisplayName','Local Steady'}); 
freqresp_bode([],YAref_fr_from_SS_local_sw, w_r, 111,'XLim',[1 1000], ...
    'H1Args', {'-', 'Color', 'b','DisplayName','test - gl st'},...
    'H2Args', {'-', 'Color', 'k','DisplayName','Local Swing'}); 
% freqresp_bode([],test_tf_fr, w_r, 111,'XLim',[1 1000], ...
%     'H1Args', {'--', 'Color', 'm','DisplayName','test ss'},...
%     'H2Args', {'--', 'Color', 'c','DisplayName','test tf'}); 

%%
k = 0.15
t = k.*reshape((YAref_fr_from_SS_local_st(2,2,:)-YAref_fr_from_SS_local_st(1,1,:)),1,1000);
t2 = reshape(YAref_fr_from_SS_local_st(1,2,:),1,1000);
t3= t2+ t
figure
semilogx(w_r./(2*pi), 20*log10(abs(t3)))
hold on
semilogx(w_r./(2*pi), 20*log10(abs(t)))
semilogx(w_r./(2*pi), 20*log10(abs(t2)))
legend("t3","t","t2")