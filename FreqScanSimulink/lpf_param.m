fc_lpf=1; %Hz;
k_lpf = 0.707; %damping ratio
fpll = 3; % pll bandwidth
Tdef_start=70;
data_length=30; %save x~s data
wc_lpf = 2*pi*fc_lpf;
fc_lpf2=0.2;
[lpf_A,lpf_B,lpf_C,lpf_D]=tf2ss([wc_lpf^2],[1, 2*k_lpf*wc_lpf,  wc_lpf^2]);
Fbase=50;

%[b_butter,a_butter] = butter(3,1/(Fs/2),'low');