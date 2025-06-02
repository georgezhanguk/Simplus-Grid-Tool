function [ICBus, ICLinkedBus] = ICBusFlag(ApparatusType, ApparatusBus,N_Bus,N_Apparatus)
    ICBus = false(1, N_Bus);  % or zeros(1, N_Bus)
    ICLinkedBus = nan(1,N_Bus);
    for k = 1:N_Apparatus
        if (ApparatusType{k} >= 2000 && ApparatusType{k} <= 2009) % can be streamlined by find
            ICBus(ApparatusBus{k}) = true;        % Mark buses connected to IC as true
            ICLinkedBus(ApparatusBus{k}(1))=ApparatusBus{k}(2);
            ICLinkedBus(ApparatusBus{k}(2))=ApparatusBus{k}(1);
        end
    end
end