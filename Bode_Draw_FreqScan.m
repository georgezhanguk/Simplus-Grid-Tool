clear FS_Final
FS_Final.freq =out.FS_Freq_point(1:2:end);
FS_Final.dd = out.FS_Result(1:2:end,1);
FS_Final.qd = out.FS_Result(1:2:end,2);
FS_Final.dq = out.FS_Result(2:2:end,1);
FS_Final.qq = out.FS_Result(2:2:end,2);
% 
% % create frequency response dataset
% FS_Final.dd_frd = frd(FS_Final.dd,FS_Final.freq,'FrequencyUnit','Hz');
% FS_Final.dq_frd = frd(FS_Final.dq,FS_Final.freq,'FrequencyUnit','Hz');
% FS_Final.qd_frd = frd(FS_Final.qd,FS_Final.freq,'FrequencyUnit','Hz');
% FS_Final.qq_frd = frd(FS_Final.qq,FS_Final.freq,'FrequencyUnit','Hz');


%% SS result
OmegaP = logspace(-1,4,500)*2*pi;
ApparatusSSModel = dss2ss(GmDssCell{2});
ApparatusSymModel =  SimplusGT.ss2sym(ApparatusSSModel);
Yref_fr = freqresp(ApparatusSSModel, w_r); 
Yref_fr = Yref_fr(1:3,1:3,:); 
%%
w_r = FS_Final.freq*2*pi;
%clear Y_fr Yref_fr;
w0=Fbase*2*pi;
R1=1e-3;
L1=1e-2;
R2=3;
L2=0.5;
s=tf('s');
Z1=[R1+s*L1, -w0*L1; w0*L1, R1+s*L1]; 
Z2=[R2+s*L2, -w0*L2; w0*L2, R1+s*L2];
%Yref = inv(Z1+Z2);
%Yref_fr = freqresp(Yref,w_r);
for i=1:length(w_r)
    Y_fr(:,:,i)=[FS_Final.dd(i),FS_Final.dq(i);FS_Final.qd(i),FS_Final.qq(i)];
    %Yref_fr(:,:,i)=inv([R1+1i*w_r(i)*L1, -w0*L1; w0*L1, R1+1i*w_r(i)*L1]+[R2+1i*w_r(i)*L2, -w0*L2; w0*L2, R2+1i*w_r(i)*L2]);
end
freqresp_bode_cpr(Y_fr,Yref_fr,w_r,100,'x');

% figure(55);
% set(gcf,'Position',[643,249,1121,938])
% clf;
% subplot(4,2,1)
% bode_sc_mag(FS_Final,'dd');
% subplot(4,2,3)
% bode_sc_phase(FS_Final,'dd');
% subplot(4,2,2)
% bode_sc_mag(FS_Final,'dq');
% subplot(4,2,4)
% bode_sc_phase(FS_Final,'dq');
% subplot(4,2,5)
% bode_sc_mag(FS_Final,'qd');
% subplot(4,2,7)
% bode_sc_phase(FS_Final,'qd');
% subplot(4,2,6)
% bode_sc_mag(FS_Final,'qq');
% subplot(4,2,8)
% bode_sc_phase(FS_Final,'qq');
% 
% function bode_sc_mag(FS_Final, axis_str)
%     xx=strcmp(axis_str,{'dd','dq','qd','qq'});
%     xx1=find(xx==1);
%     switch xx1
%         case 1
%             magx=FS_Final.dd;
%         case 2
%             magx=FS_Final.dq;
%         case 3
%             magx=FS_Final.qd;
%         case 4
%             magx=FS_Final.qq;
%         otherwise
%             error('error axis selection');
%     end
%     freq=FS_Final.freq;
%     scatter(freq, 20*log10(abs(magx)), 'x');
%     title([axis_str,' Magnitude Response']);
%     %legend(['Bode ' axis_str ' amplitude']);
%     xlabel('Hz');
%     ylabel('dB');
%     grid on;
% end
% 
% function bode_sc_phase(FS_Final, axis_str)
%     xx=strcmp(axis_str,{'dd','dq','qd','qq'});
%     xx1=find(xx==1);
%     switch xx1
%         case 1
%             magx=FS_Final.dd;
%         case 2
%             magx=FS_Final.dq;
%         case 3
%             magx=FS_Final.qd;
%         case 4
%             magx=FS_Final.qq;
%         otherwise
%             error('error axis selection');
%     end
%     freq=FS_Final.freq;
%     scatter(freq, angle(magx)/2/pi*360, 'x');
%     title([axis_str,' Phase Response']);
%     %legend(['Bode ' axis_str ' amplitude']);
%     xlabel('Hz');
%     ylabel('degree');
%     grid on;
% end