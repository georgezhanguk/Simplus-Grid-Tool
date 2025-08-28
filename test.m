Gmss = dss2ss(GmDssCell{2});
Gmsym= SimplusGT.ss2sym(Gmss);
    OmegaP = logspace(-1,4,500)*2*pi;
figure(1);
clf;
subplot(2,2,1);
SimplusGT.bode_c(Gmsym(1,1), 1j*OmegaP, 'PhaseOn', 0);
hold on
SimplusGT.bode_c(Gmsym(1,2), 1j*OmegaP, 'PhaseOn', 0);
SimplusGT.bode_c(Gmsym(2,1), 1j*OmegaP, 'PhaseOn', 0);
SimplusGT.bode_c(Gmsym(2,2), 1j*OmegaP, 'PhaseOn', 0);
title('Element G(dq)');
grid on;


% --- Plot for G(1,2) ---
subplot(2, 2, 2); % Select the 2nd subplot
SimplusGT.bode_c(Gmsym(1,3), 1j*OmegaP, 'PhaseOn', 0);
hold on
SimplusGT.bode_c(Gmsym(2,3), 1j*OmegaP, 'PhaseOn', 0);
title('Element G(dqdc)');
grid on;

% --- Plot for G(2,1) ---
subplot(2, 2, 3); % Select the 3rd subplot
SimplusGT.bode_c(Gmsym(3,1), 1j*OmegaP, 'PhaseOn', 0);
hold on
SimplusGT.bode_c(Gmsym(3,2), 1j*OmegaP, 'PhaseOn', 0);
title('Element G(dcdq)');
grid on;

% --- Plot for G(2,2) ---
subplot(2, 2, 4); % Select the 4th subplot
SimplusGT.bode_c(Gmsym(3,3), 1j*OmegaP, 'PhaseOn', 0);
title('Element G(dc)');
grid on;