NumApparatus = evalin('base', 'NumApparatus');
NumBus = evalin('base', 'NumBus');
ApparatusType = evalin('base', 'ApparatusType');
ApparatusBus = evalin('base', 'ApparatusBus');
ApparatusInputStr = evalin('base', 'ApparatusInputStr');
ApparatusOutputStr = evalin('base', 'ApparatusOutputStr');
ApparatusStateStr=evalin('base', 'ApparatusStateStr');
GsysSs = evalin('base', 'GsysSs');
GmDssCell = evalin('base', 'GmDssCell');

A=GsysSs.A;
[~,D]=eig(A);
D_Hz=diag(D/(2*pi));

%% Selection of Relevant Modes for Analysis
m=1;
ModeSelect=0;
for i=1:length(D_Hz)
    if imag(D_Hz(i))<0 
        % negative imaginary part - ignored
    elseif imag(D_Hz(i))<1
        % modes smaller than 1Hz are not included
    elseif abs(imag(D_Hz(i))-Fbase)<1
        % modes close to base frequency are not included
    %elseif abs(real(D_Hz(i)))>20
        % with a real part that is very large
    elseif imag(D_Hz(i))>500
        % larger than 500 Hz are out of consideration
    %elseif abs(imag(D_Hz(i))) < (abs(real(D_Hz(i))) * 7)
        % larger than 30% damping ratio
    else
        ModeSelect(m)=i;
        m=m+1;
    end
end
%%
[MdMode,ResidueAll,ZmValAll]=...
    SimplusGT.Modal.SSCal(GsysSs, NumApparatus, ApparatusType, ModeSelect, GmDssCell, ApparatusInputStr, ApparatusOutputStr);

%% config C-IMR: Floating bus with maximum IMR value, SG with no effect on heat map, and IBR has the critical effect.
j=1;
clear CIMR;
for k=1:NumApparatus 
    if ApparatusType{k}<89 
        CIMR(j).device = k;
        CIMR(j).value = log10(100);
        CIMR(j).mode = 0;
        CIMR(j).area = "ac";
        j=j+1;
    elseif (ApparatusType{k}>=1000 && ApparatusType{k} <1089)
        CIMR(j).device = k;
        CIMR(j).value = log10(100);
        CIMR(j).mode = 0;
        CIMR(j).area = "dc";
        j=j+1;
    elseif ApparatusType{k} >= 2000 && ApparatusType{k} <= 2009 % Interlinking AC/DC Converter
        CIMR(j).device = k;
        CIMR(j+1).device = k;
        CIMR(j).value = log10(100);
        CIMR(j+1).value = log10(100);
        CIMR(j).mode = 0;
        CIMR(j+1).mode = 0;
        CIMR(j).area = "ac";
        CIMR(j+1).area = "dc"; % Interlinking converter connected buses are ordered, [ac,dc]
        j=j+2;
    end
end

%% sweep the mode
for modei=1:length(ModeSelect)
    Residue = ResidueAll{modei};
    ZmVal = ZmValAll{modei};
    SigmaMag = abs(real(MdMode(ModeSelect(modei))))*2*pi; %MdMode is in the unit of Hz, so needs to be changed to rad.
    
    for j = find(([ApparatusType{[CIMR.device]}]~=100) & ([ApparatusType{[CIMR.device]}]~=1100)) % Select non-floating apparatuses
        k = CIMR(j).device;
        if (ApparatusType{k}>=2000 && ApparatusType{k}<=2009) % Interlinking Converter
            % In List
           if CIMR(j).area == "ac"
               IMR_IC(modei,k).IC = "AC";
               IMR = SigmaMag/(norm(Residue{k}(1:2,1:2),"fro") * norm(ZmVal{k}(1:2,1:2),"fro"));
           elseif CIMR(j).area == "dc"
               IMR_IC(modei,k).IC = "DC";
               IMR = SigmaMag/(norm(Residue{k}(3,3),"fro") * norm(ZmVal{k}(3,3),"fro"));
           else
               fprintf("error")
           end
           IMR_IC(modei,k).mode = MdMode(ModeSelect(modei));
           IMR_IC(modei,k).Sigma = SigmaMag;
           % IMR_IC(modei,k).Res = SimplusGT.Frobenius_norm_n(SimplusGT.SelectFieldsIC(Residue(k),CIMR(j).area,1));
           IMR_IC(modei,k).Zm = (norm(Residue{k}(1:2,1:2),"fro") * norm(ZmVal{k}(1:2,1:2),"fro"));
           IMR_IC(modei,k).IMR = IMR;
        else % Non interlinking apparatus
           IMR = SigmaMag/(norm(Residue{k},"fro") * norm(ZmVal{k}',"fro"))
        end
        IMR_o = IMR;

        if IMR<0.01
            IMR = log10(0.01);
        else
            IMR = log10(IMR);
        end

        if IMR<CIMR(j).value
            CIMR(j).value=IMR;
            CIMR(j).mode = MdMode(ModeSelect(modei));
            CIMR(j).value_orig=IMR_o;
        end
    end
end