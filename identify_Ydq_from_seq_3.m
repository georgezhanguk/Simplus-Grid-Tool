function [Y11, Y12, Y13, Y21, Y22, Y23, Y31, Y32,Y33] ...
= identify_Ydq_from_seq_3(t,vd,vq,vdc,id,iq,idc,f, f_list);
%IDENTIFY_YDQ_FROM_SEQ  Offline dq admittance from a single run where
%                       D-injection is followed by Q-injection at each frequency.
%
% Inputs
%   Sc      : simulation log / struct that extract_signals(Sc) understands
%   f_list  : list of probe frequencies to identify
%
% Assumptions
%   - During the sweep, for each f in f_list you perform two successive segments:
%         (1) D-axis sinusoidal injection   (Q=0)
%         (2) Q-axis sinusoidal injection   (D=0)
%   - The signal 'f' returned by extract_signals is a piecewise-constant
%     *label* of the active probe frequency (so equality test works).
%
% Outputs
%   Y11,Y12,Y21,Y22 : Nx1 complex vectors (N = numel(f_list)) with
%                     Y = [Y11 Y12; Y21 Y22] at each frequency.

    Nf = numel(f_list);
    Y11 = complex(zeros(Nf,1)); Y12 = Y11; Y21 = Y11; Y22 = Y11; Y13 = Y11; 
    Y23 = Y11; Y33 = Y11; Y32 = Y11; Y31 = Y11;

    % sampling info (assume uniform)
    dt = t(2) - t(1);
    if dt <= 0 || ~isfinite(dt)
        error('identify_Ydq_from_seq:BadTime', 'Non-positive or invalid dt.');
    end

    n_cycle = 5;                 % use 5 cycles worth of samples per segment
    min_samples = 64;            % at least this many samples per window

    for k = 1:Nf
        f_probe = f_list(k);

        % --- all sample indices where this frequency label is active
        mask = round(f, 1) == round(f_probe, 1);
        idx_all = find(mask);
        if numel(idx_all) < 2
            [Y11(k),Y12(k),Y21(k),Y22(k)] = deal(NaN);  %#ok<*AGROW>
            continue;
        end
        % --- 
        t_interval = 1e-1; % Interval between injections
        t_cycle = 1/f_list(k);
        nt_interval = t_interval/dt;
        nt_cycle = t_cycle/dt;

        % % --- split into contiguous segments (runs) for this f
        % gap = find(diff(idx_all) > 1);
        % % segment boundaries in idx_all coordinates
        % seg_st = [1; gap+1];
        % seg_en = [gap; numel(idx_all)];
        % 
        % nseg = numel(seg_st);
        % if nseg < 2
        %     % need at least two segments: D then Q
        %     [Y11(k),Y12(k),Y21(k),Y22(k)] = deal(NaN);
        %     continue;
        % end

        % --- take the last two segments for this frequency
        % Interpret: 2nd-to-last = D injection, last = Q injection
        idxD = idx_all(1+nt_cycle:1+nt_cycle*9);
        idxQ = idx_all(nt_cycle*11+nt_interval:nt_cycle*19+nt_interval);
        idxDC = idx_all(end-nt_cycle*9-nt_interval:end-nt_cycle-nt_interval);

        % % --- choose steady-state tails of each segment
        % NwD = max(min_samples, round(n_cycle/(f_probe*dt)));
        % NwQ = NwD;
        % 
        % if numel(segD) < NwD || numel(segQ) < NwQ
        %     [Y11(k),Y12(k),Y21(k),Y22(k)] = deal(NaN);
        %     continue;
        % end
        % 
        % idxD = segD(end-NwD+1:end);
        % idxQ = segQ(end-NwQ+1:end);

        % --- periodic Hann windows (coherent gain not needed if phasor_at
        %     already includes whatever scaling you want; we match your style)
        wD = hann(numel(idxD), 'periodic');
        wQ = hann(numel(idxQ), 'periodic');

        % helper: detrend (linear) + window
        proc = @(sig, idx, w) detrend(sig(idx), 'linear') .* w;
        % 
        % --- phasors at f_probe for D segment (column 1)
        VdD(k) = phasor_at(t(idxD), proc(vd,idxD,wD), f_probe);
        VqD(k) = phasor_at(t(idxD), proc(vq,idxD,wD), f_probe);
        IdD(k) = phasor_at(t(idxD), proc(id,idxD,wD), f_probe);
        IqD(k) = phasor_at(t(idxD), proc(iq,idxD,wD), f_probe);

        % --- phasors at f_probe for Q segment (column 2)
        VdQ(k) = phasor_at(t(idxQ), proc(vd,idxQ,wQ), f_probe);
        VqQ(k) = phasor_at(t(idxQ), proc(vq,idxQ,wQ), f_probe);
        IdQ(k) = phasor_at(t(idxQ), proc(id,idxQ,wQ), f_probe);
        IqQ(k) = phasor_at(t(idxQ), proc(iq,idxQ,wQ), f_probe);

    % --- phasors at f_probe for D segment (column 1)
    VdD(k) = phasor_at(t(idxD), vd(idxD), f_probe);
    VqD(k) = phasor_at(t(idxD), vq(idxD), f_probe);
    VdcD(k) = phasor_at(t(idxD), vdc(idxD), f_probe);
    IdD(k) = phasor_at(t(idxD), id(idxD), f_probe);
    IqD(k) = phasor_at(t(idxD), iq(idxD), f_probe);
    IdcD(k) = phasor_at(t(idxD), idc(idxD), f_probe);
    % --- phasors at f_probe for Q segment (column 2)
    VdQ(k) = phasor_at(t(idxQ), vd(idxQ), f_probe);
    VqQ(k) = phasor_at(t(idxQ), vq(idxQ), f_probe);
    VdcQ(k) = phasor_at(t(idxQ), vdc(idxQ), f_probe);
    IdQ(k) = phasor_at(t(idxQ), id(idxQ), f_probe);
    IqQ(k) = phasor_at(t(idxQ), iq(idxQ), f_probe);
    IdcQ(k) = phasor_at(t(idxQ), vdc(idxQ), f_probe);
    % --- phasors at f_probe for DC segment (column 2)
    VdDC(k) = phasor_at(t(idxDC), vd(idxDC), f_probe);
    VqDC(k) = phasor_at(t(idxDC), vq(idxDC), f_probe);
    VdcDC(k) = phasor_at(t(idxDC), vdc(idxDC), f_probe);
    IdDC(k) = phasor_at(t(idxDC), id(idxDC), f_probe);
    IqDC(k) = phasor_at(t(idxDC), iq(idxDC), f_probe);
    IdcDC(k) = phasor_at(t(idxDC), vdc(idxDC), f_probe);

    % --- build 2×2 V and I for this frequency (store in 3D arrays)
    V(:,:,k) = [VdD(k), VdQ(k), VdDC(k);
                VqD(k), VqQ(k), VqDC(k);
                VdcD(k), VdcQ(k), VdcDC(k)];

    I(:,:,k) = [IdD(k), IdQ(k), IdDC(k);
                IqD(k), IqQ(k), IqDC(k);
                IdcD(k), IdcQ(k), IdcDC(k)];

    % --- conditioning guard (optional but recommended)
    Vk = V(:,:,k);  Ik = I(:,:,k);
    rc = rcond(Vk);
    if ~isfinite(rc) || rc < 1e-6 || ~all(isfinite(Ik(:))) || ~all(isfinite(Vk(:)))
        Y11(k)=NaN; Y12(k)=NaN; Y21(k)=NaN; Y22(k)=NaN;
        continue
    end

    % --- solve Y = I / V for this k
    Yk = Ik / Vk;     % same as Ik*inv(Vk), more stable than forming inv

    Y11(k) = Yk(1,1);  Y12(k) = Yk(1,2); Y13(k) = Yk(1,3);
    Y21(k) = Yk(2,1);  Y22(k) = Yk(2,2); Y23(k) = Yk(2,3);
    Y31(k) = Yk(3,1);  Y32(k) = Yk(3,2); Y33(k) = Yk(3,3);
    
    end
%%
figure
plot(abs(IdD))
end
