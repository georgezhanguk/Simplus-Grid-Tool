function [Y11, Y12, Y21, Y22] = identify_Ydq_from_fullscan(Sc0, Sc1, f_list)

   
    Nf = numel(f_list);
    Y11 = complex(zeros(Nf,1)); Y12 = Y11; Y21 = Y11; Y22 = Y11;

    [t0, vd0, vq0, id0, iq0,f0] = extract_signals(Sc0);
    [t1, vd1, vq1, id1, iq1,f1] = extract_signals(Sc1);
    dt = t0(2)-t0(1);  % sampling step
    n_cycle = 5;            % 5 cycle per window

    for k = 1:Nf
        f_probe = f_list(k);

        % --- find corresponding frequency range's stable state"
        idx0_all = find(f0 == f_probe);
        idx1_all = find(f1 == f_probe);
        if isempty(idx0_all) || isempty(idx1_all)
            [Y11(k),Y12(k),Y21(k),Y22(k)] = deal(NaN); continue;
        end

        Nw = max(64, round(n_cycle/(f_probe*dt)));

        idx0 = idx0_all(end-Nw+1:end);
        idx1 = idx1_all(end-Nw+1:end);

        % --- Hann window
        w0 = hann(numel(idx0),'periodic');  cg0 = sum(w0)/numel(w0);
        w1 = hann(numel(idx1),'periodic');  cg1 = sum(w1)/numel(w1);

        % --- -DC  +window
        x = @(sig, idx, w) detrend(sig(idx),'linear').*w;

        % run0
        Vd0 = phasor_at(t0(idx0), x(vd0,idx0,w0), f_probe);
        Vq0 = phasor_at(t0(idx0), x(vq0,idx0,w0), f_probe);
        Id0 = phasor_at(t0(idx0), x(id0,idx0,w0), f_probe);
        Iq0 = phasor_at(t0(idx0), x(iq0,idx0,w0), f_probe);

        % run1
        Vd1 = phasor_at(t1(idx1), x(vd1,idx1,w1), f_probe);
        Vq1 = phasor_at(t1(idx1), x(vq1,idx1,w1), f_probe);
        Id1 = phasor_at(t1(idx1), x(id1,idx1,w1), f_probe);
        Iq1 = phasor_at(t1(idx1), x(iq1,idx1,w1), f_probe);

        % --- solve Y matrix
        V = [Vd0, Vd1;  Vq0, Vq1];
        I = [Id0, Id1;  Iq0, Iq1];

        rc = rcond(V);
        if ~(isfinite(rc)) || rc < 1e-6
            [Y11(k),Y12(k),Y21(k),Y22(k)] = deal(NaN); continue;
        end

        Y = I * pinv(V);

        Y11(k)=Y(1,1); Y12(k)=Y(1,2); Y21(k)=Y(2,1); Y22(k)=Y(2,2);
    end
end
