function ApparatusImpedancePlot(GmDssCell, ApparatusImpedancePlotSelect, ApparatusType)
%% Plot Impedance Spectrum of Apparatus
% ApparatusBus
% ApparatusType
k = ApparatusImpedancePlotSelect;
% Set frequency range 
OmegaP = logspace(-1,4,500)*2*pi;
OmegaPN = [-flip(OmegaP),OmegaP];
ApparatusSSModel = dss2ss(GmDssCell{k});
ApparatusSymModel =  SimplusGT.ss2sym(ApparatusSSModel);
if ApparatusType{k} <= 89 % AC apparatus
    size = 2;
elseif ApparatusType{k} >= 1000 && ApparatusType{k} <= 1089 % Dc apparatus
    size = 1;
elseif ApparatusType{k} >= 2000 && ApparatusType{k} <= 2009 % Interlink apparatus
    size = 3;
end
title1 = ["Ydd","Ydq","Yddc","Yqd","Yqq","Yqdc","Ydcd","Ydcq","Ydcdc"];   
figure(ApparatusImpedancePlotSelect*1000);
for i = 1:size
    for u = 1:size
        subplot(3,3,3*(i-1)+u)
        SimplusGT.bode_c(ApparatusSymModel(i,u),1j*OmegaP,'PhaseOn',0);
        hold on
        title(title1(3*(i-1)+u))
        %xlim([10e0 10e3])
    end
end

% if ApparatusType{k} <= 89 % AC apparatus
%     legend("dd","dq","qd","qq")
% elseif ApparatusType{k} >= 1000 && ApparatusType{k} <= 1089 % Dc apparatus
%     legend("dc")
% elseif ApparatusType{k} >= 2000 && ApparatusType{k} <= 2009 % Interlink apparatus
%     legend("dd","dq","qd","qq","ddc","qdc","dcd","dcq","dcdc")
% end
% xlim([1 10e3])
end
