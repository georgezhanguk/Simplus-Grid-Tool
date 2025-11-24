function [t, vd, vq, id, iq, f] = extract_signals(Sc)
    t  = Sc.t(:);
    vd = Sc.vd(:);  vq = Sc.vq(:);
    id = Sc.id(:);  iq = Sc.iq(:);
    if isfield(Sc,'f'), f = Sc.f(:); else, f = NaN(size(t)); end
end
