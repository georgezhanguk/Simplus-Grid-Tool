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
%   NEW (LEGEND CONTROL)
%   --------------------
%   'LegendAxes'     : Which axes/subplot hosts the legend. Accepts:
%                      - scalar subplot index (1..8) in a 4x2 layout, or
%                      - [m n p] triple, e.g. [4 2 1], or
%                      - an axes handle.
%                      Default: [4 2 1] (top-left magnitude plot).
%
%   'LegendPosition' : Legend position in NORMALIZED FIGURE units:
%                      [x y w h]. If empty [], the legend is placed to the
%                      right of LegendAxes WITHOUT shrinking that axes.
%                      Default: [].
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
%   - A legend is created (at the end) on LegendAxes. The legend can be
%     manually positioned without compressing the selected axes.
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
%     % Put legend on top-left magnitude plot, to the right, no shrink
%     freqresp_bode(H_scan, H_model, w_vec, 1, ...
%         'LegendAxes',[4 2 1]);
%
%     % Put legend on subplot #2 and specify exact position (normalized)
%     freqresp_bode(H_scan, H_model, w_vec, 1, ...
%         'LegendAxes',2, ...
%         'LegendPosition',[0.86 0.78 0.12 0.18]);
%
%     % Plot only H1 (H2 empty)
%     freqresp_bode(H_scan, [], w_vec, 2, ...
%         'H1Args', {'DisplayName','Scan','Color','k'});
%
%   See also SEMILOGX, LEGEND.

    % -------- input parser --------
    % We support standard name-value pairs + "unmatched" pairs which are
    % treated as common line styling for both datasets.
    p = inputParser;
    p.KeepUnmatched   = true;
    p.PartialMatching = false;

    % Existing options
    addParameter(p,'XLim',[]);
    addParameter(p,'H1Args',{});
    addParameter(p,'H2Args',{});

    % NEW: Legend control
    addParameter(p,'LegendAxes',[4 2 1]); % scalar 1..8 OR [m n p] OR axes handle
    addParameter(p,'LegendPosition',[]);  % normalized [x y w h] or []

    % Parse options
    parse(p, varargin{:});
    o = p.Results;

    % Collect unmatched (common) line args and turn into a cell array
    u  = p.Unmatched;
    fn = fieldnames(u);
    commonArgs = cell(1, 2*numel(fn));
    for i = 1:numel(fn)
        commonArgs{2*i-1} = fn{i};
        commonArgs{2*i}   = u.(fn{i});
    end

    % Per-dataset styling
    h1Args = o.H1Args;
    h2Args = o.H2Args;

    % Data availability flags
    hasH1 = ~isempty(h1);
    hasH2 = ~isempty(h2);

    % If nothing to plot, exit gracefully
    if ~hasH1 && ~hasH2
        warning('freqresp_bode:NoData','Both h1 and h2 are empty – nothing to plot.');
        return;
    end

    % -------- axes styling helper --------
    % Applies common axis settings for all subplots.
    function style_axes(ax)
        if nargin < 1 || isempty(ax), ax = gca; end
        ax.XScale     = 'log';
        ax.Box        = 'on';
        ax.XMinorGrid = 'on';
        ax.YMinorGrid = 'on';
        grid(ax,'on');
    end

    % -------- phase computation helper --------
    % Unwrap phase and return degrees. If both datasets exist, align the
    % initial phase of dataset 1 (H1) to dataset 2 (H2) by shifting by
    % multiples of 360 degrees.
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

    % -------- legend-axes resolver --------
    % Converts LegendAxes spec into a concrete axes handle.
    % Accepts:
    %   - axes handle
    %   - scalar subplot index (1..8) for a 4x2 grid
    %   - [m n p] triple (subplot args)
    function ax = resolve_legend_axes(spec)
        if isgraphics(spec,'axes')
            ax = spec;  % already an axes handle
            return;
        end

        if isnumeric(spec)
            if isscalar(spec)
                ax = subplot(4,2,spec);
                return;
            elseif numel(spec) == 3
                ax = subplot(spec(1),spec(2),spec(3));
                return;
            end
        end

        warning('freqresp_bode:BadLegendAxes', ...
            'LegendAxes must be an axes handle, a scalar subplot index, or [m n p]. Using [4 2 1].');
        ax = subplot(4,2,1);
    end

    % Convert rad/s to Hz for plotting
    w_f = w_r/2/pi;

    % Activate target figure
    figure(fig_k);

    % ================== Ydd MAG (subplot 1) ==================
    ax11 = subplot(4,2,1); hold(ax11,'on');
    if hasH1
        z1 = squeeze(h1(1,1,:));
        semilogx(w_f, 20*log10(abs(z1)), commonArgs{:}, h1Args{:});
    end
    if hasH2
        z2 = squeeze(h2(1,1,:));
        semilogx(w_f, 20*log10(abs(z2)), commonArgs{:}, h2Args{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes(ax11);
    title('Y_{dd}');

    % ================== Ydd PHASE (subplot 3) ==================
    ax13 = subplot(4,2,3); hold(ax13,'on');
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
    style_axes(ax13);

    % ================== Ydq MAG (subplot 2) ==================
    ax12 = subplot(4,2,2); hold(ax12,'on');
    if hasH1
        z1 = squeeze(h1(1,2,:));
        semilogx(w_f, 20*log10(abs(z1)), commonArgs{:}, h1Args{:});
    end
    if hasH2
        z2 = squeeze(h2(1,2,:));
        semilogx(w_f, 20*log10(abs(z2)), commonArgs{:}, h2Args{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes(ax12);
    title('Y_{dq}');

    % ================== Ydq PHASE (subplot 4) ==================
    ax14 = subplot(4,2,4); hold(ax14,'on');
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
    style_axes(ax14);

    % ================== Yqd MAG (subplot 5) ==================
    ax15 = subplot(4,2,5); hold(ax15,'on');
    if hasH1
        z1 = squeeze(h1(2,1,:));
        semilogx(w_f, 20*log10(abs(z1)), commonArgs{:}, h1Args{:});
    end
    if hasH2
        z2 = squeeze(h2(2,1,:));
        semilogx(w_f, 20*log10(abs(z2)), commonArgs{:}, h2Args{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes(ax15);
    title('Y_{qd}');

    % ================== Yqd PHASE (subplot 7) ==================
    ax17 = subplot(4,2,7); hold(ax17,'on');
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
    style_axes(ax17);

    % ================== Yqq MAG (subplot 6) ==================
    ax16 = subplot(4,2,6); hold(ax16,'on');
    if hasH1
        z1 = squeeze(h1(2,2,:));
        semilogx(w_f, 20*log10(abs(z1)), commonArgs{:}, h1Args{:});
    end
    if hasH2
        z2 = squeeze(h2(2,2,:));
        semilogx(w_f, 20*log10(abs(z2)), commonArgs{:}, h2Args{:});
    end
    ylabel('Magnitude (dB)');
    if ~isempty(o.XLim), xlim(o.XLim); end
    style_axes(ax16);
    title('Y_{qq}');

    % ================== Yqq PHASE (subplot 8) ==================
    ax18 = subplot(4,2,8); hold(ax18,'on');
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
    style_axes(ax18);

    % ================== LEGEND (created at the end) ==================
    % We create/move the legend AFTER all plotting is done so that:
    %   - it can host entries from whichever curves exist,
    %   - it can be attached to any chosen axes,
    %   - we can prevent MATLAB from shrinking the chosen axes.
    axL = resolve_legend_axes(o.LegendAxes);

    % Save axes position BEFORE legend creation (legend can resize axes)
    posAx = axL.Position;

    % Create legend showing objects that have DisplayName set
    lgd = legend(axL,'show');
    drawnow;

    % Restore axes size to prevent compression
    axL.Position = posAx;

    % Place legend: either exact user position or default "right side"
    lgd.Units = 'normalized';
    if ~isempty(o.LegendPosition)
        lgd.Location = 'none';
        lgd.Position = o.LegendPosition;      % user supplied normalized figure coords
    else
        lgd.Location = 'none';
        gap = 0.01;                           % small gap between axes and legend
        lgdW = 0.16;                          % legend width (tune if needed)
        lgd.Position = [posAx(1)+posAx(3)+gap, posAx(2), lgdW, posAx(4)];
    end
end

