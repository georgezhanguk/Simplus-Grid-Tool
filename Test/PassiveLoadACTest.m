%% Comparison of Theory SS and Simplus GT SS from PassiveACLoad Class
w0 = 2*pi*50;
RA=1;
LA=2;
RG=0.02;
LG=0.1;
s=tf('s');
ZA=[RA+s*LA, -w0*LA; w0*LA, RA+s*LA]; 
ZG=[RG+s*LG, -w0*LG; w0*LG, RG+s*LG];
k=2
Yref = inv(ZA+ZG);
OmegaP = logspace(-1,4,500)*2*pi;
Yref_fr = freqresp(Yref,OmegaP)
Y_fr = freqresp(GsysSs(PortBusI{k},PortBusV{k}),OmegaP)
figure(1001)
freqresp_bode(Yref_fr,Y_fr,OmegaP,1001)
