function freqresp_bode(h1, h2, w_r, fig_k, varargin)
%FREQRESP_BODE  Plot 2x2 dq admittance/impedance Bode diagrams (mag/phase).
%
%   FREQRESP_BODE(H1, H2, W_R, FIG_K) creates a 4x2 grid of subplots
%   showing magnitude (dB) and phase (deg) of the 2x2 dq frequency
%   response matrix:
%
%       [Y_dd  Y_dq
%        Y_qd  Y_qq]
%
%   for up to two datasets H1 and H2.
%
%   INPUTS
%   ------
%   H1, H2 : 2x2xN complex arrays (can be []), typically admittance or
%            impedance in the dq-frame over frequency. The (i,j,:) element
%            is the response from input j to output i.
%
%   W_R    : 1xN or Nx1 vector of angular frequencies in rad/s.
%            Internally, the function converts to Hz as:
%
%                W_F = W_R / (2*pi)
%
%   FIG_K  : Figure handle or figure number to plot into.
%
%   OPTIONAL NAME-VALUE PAIRS
%   -------------------------
%   'XLim'   : [w_min w_max] in Hz for all subplots (default: []).
%
%   'H1Args' : Cell array of line-style arguments applied only to H1
%              plots. Example:
%                   'H1Args', {'DisplayName','Scan', ...
%                              'LineStyle','-', ...
%                              'Marker','o'}
%
%   'H2Args' : Cell array of line-style arguments applied only to H2
%              plots. Example:
%                   'H2Args', {'DisplayName','Model', ...
%                              'LineStyle','--'}
%
%   Any additional (unmatched) name-value pairs are treated as COMMON
%   line arguments applied to BOTH H1 and H2 curves (e.g. 'LineWidth',2).
%
%   BEHAVIOUR
%   ---------
%   - If both H1 and H2 are empty, the function issues a warning and
%     returns without plotting.
%   - Axes are log-scaled in frequency, with grid and minor grid on.
%   - Subplot layout (4 rows x 2 columns):
%       (1,1)  |Y_dd| (dB)
%       (2,1)  arg(Y_dd) (deg)
%       (1,2)  |Y_dq| (dB)
%       (2,2)  arg(Y_dq) (deg)
%       (3,1)  |Y_qd| (dB)
%       (4,1)  arg(Y_qd) (deg)
%       (3,2)  |Y_qq| (dB)
%       (4,2)  arg(Y_qq) (deg)
%
%   - Phase is unwrapped and expressed in degrees. If both H1 and H2 are
%     provided, the phase of H1 is shifted by an integer multiple of
%     360 degrees so that ph1(1) is roughly aligned with ph2(1).
%   - A legend is created in the Y_dd magnitude subplot. To control labels,
%     pass 'DisplayName' via H1Args/H2Args and then adjust the legend
%     outside the function if needed.
%
%   EXAMPLES
%   --------
%     % Basic usage with two datasets
%     freqresp_bode(H_scan, H_model, w_vec, 1, ...
%         'XLim', [1 1e3], ...
%         'LineWidth', 1.5, ...             % common to both
%         'H1Args', {'DisplayName','Scan',  'LineStyle','-'}, ...
%         'H2Args', {'DisplayName','Model', 'LineStyle','--'});
%
%     % Move legend after plotting
%     subplot(4,2,1);
%     leg = legend;
%     leg.Location = 'southwest';
%
%     % Plot only H1 (H2 empty)
%     freqresp_bode(H_scan, [], w_vec, 2, ...
%         'H1Args', {'DisplayName','Scan','Color','k'});
%
%   See also SEMILOGX, LEGEND.

    % -------- input parser --------
    p = inputParser;
    p.KeepUnmatched   = true;
    p.PartialMatching = false;

    addParameter(p,'XLim',[]);
    addParameter(p,'H1Args',{});
    addParameter(p,'H2Args',{});

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

    h1Args = o.H1Args;
    h2Args = o.H2Args;

    hasH1 = ~isempty(h1);
    hasH2 = ~isempty(h2);

    if ~hasH1 && ~hasH2
        warning('freqresp_bode:NoData','Both h1 and h2 are empty – nothing to plot.');
        return;
    end

    function style_axes()
        ax = gca;
        ax.XScale     = 'log';
        ax.Box        = 'on';
        ax.XMinorGrid = 'on';
        ax.YMinorGrid = 'on';
        grid(ax,'on');
    end

    % -------- Phase computation helper --------
    function [ph1,ph2] = compute_phase(z1,z2)
        if nargin >= 1 && ~isempty(z1)
            ph1 = rad2deg(unwrap(angle(z1)));
        else
            ph1 = [];
        end
        if nargin >= 2 && ~isempty(z2)
            ph2 = rad2deg(unwrap(angle(z2)));
        else
            ph2 = [];
        end

        % Align initial phase if both present
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
        semilogx(w_f, 20*log10(abs(z1)), ...
            commonArgs{:}, h1Args{:});
    end
    if hasH2
        z2 = squeeze(h2(1,1,:));
        semilogx(w_f, 20*log10(abs(z2)), ...
            commonArgs{:}, h2Args{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();
    legend('show');
    title('Y_{dd}')

    % ================== Ydd PHASE ==================
    subplot(4,2,3); hold on;
    z1 = []; z2 = [];
    if hasH1, z1 = squeeze(h1(1,1,:)); end
    if hasH2, z2 = squeeze(h2(1,1,:)); end
    [ph1,ph2] = compute_phase(z1,z2);

    if hasH1
        semilogx(w_f, ph1, commonArgs{:}, h1Args{:});
    end
    if hasH2
        semilogx(w_f, ph2, commonArgs{:}, h2Args{:});
    end
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();

    % ================== Ydq MAG ==================
    subplot(4,2,2); hold on;
    if hasH1
        z1 = squeeze(h1(1,2,:));
        semilogx(w_f, 20*log10(abs(z1)), ...
            commonArgs{:}, h1Args{:});
    end
    if hasH2
        z2 = squeeze(h2(1,2,:));
        semilogx(w_f, 20*log10(abs(z2)), ...
            commonArgs{:}, h2Args{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();
    title('Y_{dq}')

    % ================== Ydq PHASE ==================
    subplot(4,2,4); hold on;
    z1 = []; z2 = [];
    if hasH1, z1 = squeeze(h1(1,2,:)); end
    if hasH2, z2 = squeeze(h2(1,2,:)); end
    [ph1,ph2] = compute_phase(z1,z2);

    if hasH1
        semilogx(w_f, ph1, commonArgs{:}, h1Args{:});
    end
    if hasH2
        semilogx(w_f, ph2, commonArgs{:}, h2Args{:});
    end
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();

    % ================== Yqd MAG ==================
    subplot(4,2,5); hold on;
    if hasH1
        z1 = squeeze(h1(2,1,:));
        semilogx(w_f, 20*log10(abs(z1)), ...
            commonArgs{:}, h1Args{:});
    end
    if hasH2
        z2 = squeeze(h2(2,1,:));
        semilogx(w_f, 20*log10(abs(z2)), ...
            commonArgs{:}, h2Args{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();
    title('Y_{qd}')

    % ================== Yqd PHASE ==================
    subplot(4,2,7); hold on;
    z1 = []; z2 = [];
    if hasH1, z1 = squeeze(h1(2,1,:)); end
    if hasH2, z2 = squeeze(h2(2,1,:)); end
    [ph1,ph2] = compute_phase(z1,z2);

    if hasH1
        semilogx(w_f, ph1, commonArgs{:}, h1Args{:});
    end
    if hasH2
        semilogx(w_f, ph2, commonArgs{:}, h2Args{:});
    end
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();

    % ================== Yqq MAG ==================
    subplot(4,2,6); hold on;
    if hasH1
        z1 = squeeze(h1(2,2,:));
        semilogx(w_f, 20*log10(abs(z1)), ...
            commonArgs{:}, h1Args{:});
    end
    if hasH2
        z2 = squeeze(h2(2,2,:));
        semilogx(w_f, 20*log10(abs(z2)), ...
            commonArgs{:}, h2Args{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();
    title('Y_{qq}')

    % ================== Yqq PHASE ==================
    subplot(4,2,8); hold on;
    z1 = []; z2 = [];
    if hasH1, z1 = squeeze(h1(2,2,:)); end
    if hasH2, z2 = squeeze(h2(2,2,:)); end
    [ph1,ph2] = compute_phase(z1,z2);

    if hasH1
        semilogx(w_f, ph1, commonArgs{:}, h1Args{:});
    end
    if hasH2
        semilogx(w_f, ph2, commonArgs{:}, h2Args{:});
    end
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes();
end
