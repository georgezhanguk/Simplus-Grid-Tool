%% Test Script for Offline Analysis of SIDIB System
% Author: George Zhang
% Date: 02/10/2025
% Adapted from Yuming's frequency scanning code, this test script is to
% perform offline analysis of the simulation, to see if correct frequency
% scanning results can be obtained, before these corrections might be
% transferred to the real-time frequency scanning block
% Data needs to be first manipulated into chunks.
F_point = out.f_point.Data; % Test frequency injected
id = out.measuredvi.Data(:,1); % id current
iq = out.measuredvi.Data(:,2); % iq current
vd = out.measuredvi.Data(:,3); % vd current
vq = out.measuredvi.Data(:,4); % vq current
idc = out.measuredvi.Data(:,5); % vd current
vdc = out.measuredvi.Data(:,6); % vq current
t = out.measuredvi.Time; % id current
f_list = logspace(1,4,50);
[Y11, Y12, Y13, Y21, Y22, Y23, Y31, Y32,Y33] ...
= identify_Ydq_from_seq_3(t,vd,vq,vdc,id,iq,idc,F_point, f_list);

%%
f_list = [10
11.51395399
13.25711366
15.26417967
17.57510625
20.23589648
23.29951811
26.82695795
30.88843596
35.56480306
40.94915062
47.14866363
54.28675439
62.50551925
71.9685673
82.86427729
95.40954763
109.8541142
126.4855217
145.6348478
167.6832937
193.0697729
222.2996483
255.9547923
294.7051703
339.3221772
390.6939937
449.8432669
517.9474679
596.3623317
686.648845
790.6043211
910.298178
1048.113134
1206.792641
1389.495494
1599.85872
1842.069969
2120.950888
2442.053095
2811.768698
3237.457543
3727.59372
4291.93426
4941.713361
5689.866029
6551.285569
7543.120063
8685.113738
10000
]
%%
figure
plot(abs(Y11))