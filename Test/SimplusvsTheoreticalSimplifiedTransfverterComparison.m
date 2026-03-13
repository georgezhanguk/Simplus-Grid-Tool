% test
testss=TheoreticalImpedanceTransfverter(x_e,u_e,ApparatusPara,ApparatusPowerFlow,2);
ApparatusImpedancePlot(Gm_local{2}, 2, ApparatusType,1)
%ApparatusImpedancePlot(dss2ss(GmDssCell{2}), 2, ApparatusType,1)
ApparatusImpedancePlot(testss, 2, ApparatusType,1,'LineStyle','--')
ApparatusImpedancePlot(Gm_local_ddc_003{2}, 2, ApparatusType,1)
%ApparatusImpedancePlot(dss2ss(GmDssCell{2}), 2, ApparatusType,1)
ApparatusImpedancePlot(testss_ddc_003, 2, ApparatusType,1,'LineStyle','--')
legend("SimplusGT SS","Theoretical")