% % % h1: estimated
% % % h2: reference
% function freqresp_bode_cpr(h1, h2, w_r, fig_k, shape, varargin)
%     % Optional name-value parameters:
%     %   'XLim', [xmin xmax]              % apply same x-limits (Hz) to all panels
%     %   'LegendStrings', {'Scan','Ref'}  % legend labels
%     %   'ScanArgs', {...}                % extra line props for first (scan/estimated) series
%     %   'RefArgs',  {...}                % extra line props for second (reference) series
%     % Plus ANY standard line properties (e.g., 'LineWidth',2,'MarkerSize',4,...) which
%     % will be applied to BOTH lines unless overridden by ScanArgs/RefArgs.
% 
%     % -------- input parser --------
%     p = inputParser;
%     p.KeepUnmatched   = true;     % allow standard line properties (LineWidth, Color, etc.)
%     p.PartialMatching = false;    % avoid accidental partial matches
%     addParameter(p,'XLim',[]);                                % same x-limits for all subplots
%     addParameter(p,'LegendStrings',{'Frequency Scan','Reference'});
%     addParameter(p,'ScanArgs',{});                            % per-series overrides
%     addParameter(p,'RefArgs',{});                             % per-series overrides
%     parse(p, varargin{:});
%     o = p.Results;
% 
%     % Collect unmatched (common) line args
%     u  = p.Unmatched;
%     fn = fieldnames(u);
%     commonArgs = cell(1, 2*numel(fn));
%     for i = 1:numel(fn)
%         commonArgs{2*i-1} = fn{i};
%         commonArgs{2*i}   = u.(fn{i});
%     end
% 
%     w_f = w_r/2/pi;
% 
%     figure(fig_k); %clf;
% 
%     % ===== (1,1) MAG =====
%     subplot(4,2,1)
%     z1 = squeeze(h1(1,1,:));  z2 = squeeze(h2(1,1,:));
%     mag1 = 20*log10(abs(z1)); mag2 = 20*log10(abs(z2));
%     semilogx(w_f, mag1, shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     semilogx(w_f, mag2,        'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
%     ylabel('Magnitude (dB)'); legend('show'); if ~isempty(o.XLim), xlim(o.XLim); end; grid on;
%     title('Z_{dd}')
% 
%     % ===== (1,1) PHASE =====
%     subplot(4,2,3)
%     phase_deg1 = rad2deg(unwrap(angle(z1)));
%     phase_deg2 = rad2deg(unwrap(angle(z2)));
%     offset = phase_deg1(1) - phase_deg2(1);
%     phase_aligned1 = phase_deg1 - round(offset/360)*360;
%     % semilogx(w_f, phase_aligned1, shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     % semilogx(w_f, phase_deg2,            'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
%     semilogx(w_f, angle(z1), shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     semilogx(w_f, angle(z2),            'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
% 
%     xlabel('Frequency (Hz)'); ylabel('Phase (degrees)'); if ~isempty(o.XLim), xlim(o.XLim); end; grid on;
% 
%     % ===== (1,2) MAG =====
%     subplot(4,2,2)
%     z1 = squeeze(h1(1,2,:));  z2 = squeeze(h2(1,2,:));
%     mag1 = 20*log10(abs(z1)); mag2 = 20*log10(abs(z2));
%     semilogx(w_f, mag1, shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     semilogx(w_f, mag2,        'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
%     ylabel('Magnitude (dB)'); if ~isempty(o.XLim), xlim(o.XLim); end; grid on;
%     title('Z_{dq}')
%     % ===== (1,2) PHASE =====
%     subplot(4,2,4)
%     phase_deg1 = rad2deg(unwrap(angle(z1)));
%     phase_deg2 = rad2deg(unwrap(angle(z2)));
%     offset = phase_deg1(1) - phase_deg2(1);
%     phase_aligned1 = phase_deg1 - round(offset/360)*360;
%     % semilogx(w_f, phase_aligned1, shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     % semilogx(w_f, phase_deg2,            'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
%     semilogx(w_f, angle(z1), shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     semilogx(w_f, angle(z2),            'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
% 
%     xlabel('Frequency (Hz)'); ylabel('Phase (degrees)'); if ~isempty(o.XLim), xlim(o.XLim); end; grid on;
% 
%     % ===== (2,1) MAG =====
%     subplot(4,2,5)
%     z1 = squeeze(h1(2,1,:));  z2 = squeeze(h2(2,1,:));
%     mag1 = 20*log10(abs(z1)); mag2 = 20*log10(abs(z2));
%     semilogx(w_f, mag1, shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     semilogx(w_f, mag2,        'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
%     ylabel('Magnitude (dB)'); if ~isempty(o.XLim), xlim(o.XLim); end; grid on;
%     title('Z_{qd}')
% 
%     % ===== (2,1) PHASE =====
%     subplot(4,2,7)
%     phase_deg1 = rad2deg(unwrap(angle(z1)));
%     phase_deg2 = rad2deg(unwrap(angle(z2)));
%     offset = phase_deg1(1) - phase_deg2(1);
%     phase_aligned1 = phase_deg1 - round(offset/360)*360;
%     % semilogx(w_f, phase_aligned1, shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     % semilogx(w_f, phase_deg2,            'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
%     semilogx(w_f, angle(z1), shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     semilogx(w_f, angle(z2),            'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
%     xlabel('Frequency (Hz)'); ylabel('Phase (degrees)'); if ~isempty(o.XLim), xlim(o.XLim); end; grid on;
% 
%     % ===== (2,2) MAG =====
%     subplot(4,2,6)
%     z1 = squeeze(h1(2,2,:));  z2 = squeeze(h2(2,2,:));
%     mag1 = 20*log10(abs(z1)); mag2 = 20*log10(abs(z2));
%     semilogx(w_f, mag1, shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     semilogx(w_f, mag2,        'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
%     ylabel('Magnitude (dB)'); if ~isempty(o.XLim), xlim(o.XLim); end; grid on;
%     title('Z_{qq}')
% 
%     % ===== (2,2) PHASE =====
%     subplot(4,2,8)
%     phase_deg1 = rad2deg(unwrap(angle(z1)));
%     phase_deg2 = rad2deg(unwrap(angle(z2)));
%     offset = phase_deg1(1) - phase_deg2(1);
%     phase_aligned1 = phase_deg1 - round(offset/360)*360;
%     % semilogx(w_f, phase_aligned1, shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     % semilogx(w_f, phase_deg2,            'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
%     semilogx(w_f, angle(z1), shape, 'DisplayName', o.LegendStrings{1}, commonArgs{:}, o.ScanArgs{:}); hold on;
%     semilogx(w_f, angle(z2),            'DisplayName', o.LegendStrings{2}, commonArgs{:}, o.RefArgs{:});
%     xlabel('Frequency (Hz)'); ylabel('Phase (degrees)'); if ~isempty(o.XLim), xlim(o.XLim); end; grid on;
% end
function freqresp_bode_cpr(h1, h2, w_r, fig_k, shape, varargin)
    % -------- input parser --------
    p = inputParser;
    p.KeepUnmatched   = true;
    p.PartialMatching = false;

    addParameter(p,'XLim',[]);
    addParameter(p,'LegendStrings',{'Frequency Scan','Reference'});
    addParameter(p,'ScanArgs',{});
    addParameter(p,'RefArgs',{});

    parse(p, varargin{:});
    o = p.Results;

    % Collect unmatched (common) line args
    u  = p.Unmatched;
    fn = fieldnames(u);
    commonArgs = cell(1, 2*numel(fn));
    for i = 1:numel(fn)
        commonArgs{2*i-1} = fn{i};
        commonArgs{2*i}   = u.(fn{i});
    end

    hasH1 = ~isempty(h1);
    hasH2 = ~isempty(h2);

    if ~hasH1 && ~hasH2
        warning('freqresp_bode_cpr:NoData','Both h1 and h2 are empty – nothing to plot.');
        return;
    end

    function [name1,name2] = getNames()
        name1 = ''; name2 = '';
        if hasH1 && hasH2
            if numel(o.LegendStrings)>=2
                name1=o.LegendStrings{1};
                name2=o.LegendStrings{2};
            end
        elseif hasH1
            name1 = o.LegendStrings{1};
        elseif hasH2
            if numel(o.LegendStrings)>=2
                name2=o.LegendStrings{2};
            else
                name2=o.LegendStrings{1};
            end
        end
    end
    [name1,name2] = getNames();

    function style_axes()
        ax=gca;
        ax.XScale='log';
        ax.Box='on';
        ax.XMinorGrid='on';
        ax.YMinorGrid='on';
        grid(ax,'on');
    end

    % -------- Phase computation helper --------
    function [ph1,ph2] = compute_phase(z1,z2)
        if nargin>=1 && ~isempty(z1)
            ph1 = rad2deg(unwrap(angle(z1)));
        else
            ph1 = [];
        end
        if nargin>=2 && ~isempty(z2)
            ph2 = rad2deg(unwrap(angle(z2)));
        else
            ph2 = [];
        end

        if ~isempty(ph1) && ~isempty(ph2)
            offset = ph1(1) - ph2(1);
            ph1 = ph1 - round(offset/360)*360;
        end
    end

    w_f = w_r/2/pi;

    figure(fig_k);

    % ================== Ydd MAG ==================
    subplot(4,2,1); hold on;
    if hasH1
        z1 = squeeze(h1(1,1,:));
        semilogx(w_f, 20*log10(abs(z1)), shape, ...
            'DisplayName', name1, commonArgs{:}, o.ScanArgs{:});
    end
    if hasH2
        z2 = squeeze(h2(1,1,:));
        semilogx(w_f, 20*log10(abs(z2)), ...
            'DisplayName', name2, commonArgs{:}, o.RefArgs{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();
    legend('show');
    title('Z_{dd}')

    % ================== Ydd PHASE ==================
    subplot(4,2,3); hold on;
    z1 = []; z2 = [];
    if hasH1, z1=squeeze(h1(1,1,:)); end
    if hasH2, z2=squeeze(h2(1,1,:)); end
    [ph1,ph2] = compute_phase(z1,z2);

    if hasH1
        semilogx(w_f, ph1, shape, 'DisplayName', name1, commonArgs{:}, o.ScanArgs{:});
    end
    if hasH2
        semilogx(w_f, ph2, 'DisplayName', name2, commonArgs{:}, o.RefArgs{:});
    end
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();

    % ================== Ydq MAG ==================
    subplot(4,2,2); hold on;
    if hasH1
        z1=squeeze(h1(1,2,:));
        semilogx(w_f,20*log10(abs(z1)),shape,...
            'DisplayName',name1,commonArgs{:},o.ScanArgs{:});
    end
    if hasH2
        z2=squeeze(h2(1,2,:));
        semilogx(w_f,20*log10(abs(z2)),...
            'DisplayName',name2,commonArgs{:},o.RefArgs{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();
    title('Z_{dq}')

    % ================== Ydq PHASE ==================
    subplot(4,2,4); hold on;
    z1=[]; z2=[];
    if hasH1, z1=squeeze(h1(1,2,:)); end
    if hasH2, z2=squeeze(h2(1,2,:)); end
    [ph1,ph2] = compute_phase(z1,z2);

    if hasH1
        semilogx(w_f, ph1, shape, 'DisplayName', name1, commonArgs{:}, o.ScanArgs{:});
    end
    if hasH2
        semilogx(w_f, ph2, 'DisplayName', name2, commonArgs{:}, o.RefArgs{:});
    end
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();

    % ================== Yqd MAG ==================
    subplot(4,2,5); hold on;
    if hasH1
        z1=squeeze(h1(2,1,:));
        semilogx(w_f,20*log10(abs(z1)),shape,...
            'DisplayName',name1,commonArgs{:},o.ScanArgs{:});
    end
    if hasH2
        z2=squeeze(h2(2,1,:));
        semilogx(w_f,20*log10(abs(z2)),...
            'DisplayName',name2,commonArgs{:},o.RefArgs{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();
    title('Z_{qd}')

    % ================== Yqd PHASE ==================
    subplot(4,2,7); hold on;
    z1=[]; z2=[];
    if hasH1, z1=squeeze(h1(2,1,:)); end
    if hasH2, z2=squeeze(h2(2,1,:)); end
    [ph1,ph2] = compute_phase(z1,z2);

    if hasH1
        semilogx(w_f, ph1, shape, 'DisplayName', name1, commonArgs{:}, o.ScanArgs{:});
    end
    if hasH2
        semilogx(w_f, ph2, 'DisplayName', name2, commonArgs{:}, o.RefArgs{:});
    end
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();

    % ================== Yqq MAG ==================
    subplot(4,2,6); hold on;
    if hasH1
        z1=squeeze(h1(2,2,:));
        semilogx(w_f,20*log10(abs(z1)),shape,...
            'DisplayName',name1,commonArgs{:},o.ScanArgs{:});
    end
    if hasH2
        z2=squeeze(h2(2,2,:));
        semilogx(w_f,20*log10(abs(z2)),...
            'DisplayName',name2,commonArgs{:},o.RefArgs{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();
    title('Z_{qq}')

    % ================== Yqq PHASE ==================
    subplot(4,2,8); hold on;
    z1=[]; z2=[];
    if hasH1, z1=squeeze(h1(2,2,:)); end
    if hasH2, z2=squeeze(h2(2,2,:)); end
    [ph1,ph2] = compute_phase(z1,z2);

    if hasH1
        semilogx(w_f, ph1, shape, 'DisplayName', name1, commonArgs{:}, o.ScanArgs{:});
    end
    if hasH2
        semilogx(w_f, ph2, 'DisplayName', name2, commonArgs{:}, o.RefArgs{:});
    end
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();
end
