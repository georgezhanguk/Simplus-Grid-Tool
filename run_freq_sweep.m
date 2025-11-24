function Y_results = run_freq_sweep(opts)
% RUN_FREQ_SWEEP  Simulink-based frequency sweep to identify dq admittance.
%   Yuming
% This routine:
%   1) builds a log-spaced probe-frequency list,
%   2) for each frequency runs the Simulink model twice with harmonics_deg
%      = 0 deg and 90 deg (two linearly independent excitations on dq),
%   3) extracts complex phasors of (v_d, v_q, i_d, i_q) at the probe freq
%      using robust least-squares (works with variable-step solvers),
%   4) computes Ydq(ω) via least-squares:  I ≈ Y * V  =>  Y = I * pinv(V),
%   5) plots |Y| and ∠Y, and saves results.
%
% Required in BASE workspace (the model must read them via mask/blocks):
%   f_start, f_end, n_sample, t_interval, submag, supmag, harmonics_deg
%
% The Simulink model must store a struct 'Scope_data' in BASE workspace
% with fields: time, v_d, v_q, i_d, i_q  (column vectors).
%
% OUTPUT:
%   Y_results struct with fields:
%       f_list, Y11, Y12, Y21, Y22

    % ---------- Defaults & options ----------
    if nargin < 1, opts = struct(); end

    % Name of the Simulink model
    if ~isfield(opts,'model'),     opts.model = 'Frequency_scanning'; end
    % Workspace variable containing measured signals
    if ~isfield(opts,'scopeVar'),  opts.scopeVar = 'simout'; end

    % Sweep definition
    if ~isfield(opts,'f_start'),   opts.f_start = 0.1;      end
    if ~isfield(opts,'f_end'),     opts.f_end   = 1e4;      end
    if ~isfield(opts,'n_sample'),  opts.n_sample= 100;      end
    if ~isfield(opts,'settle_time'),opts.settle_time = 0.2;   end
    if ~isfield(opts,'cycles_n'),  opts.cycles_n = 10;   end
    if ~isfield(opts,'submag'),    opts.submag  = 0.005;    end
    if ~isfield(opts,'supmag'),    opts.supmag  = 0.005;    end
    if ~isfield(opts,'P'),         opts.P  = 0.2;    end
    if ~isfield(opts,'Q'),         opts.Q  = 0.1;    end
    if ~isfield(opts,'V0'),        opts.V0  = 0.9;    end
    if ~isfield(opts,'start_time'),        opts.start_time  = 1;    end
    if ~isfield(opts,'phase_list_deg'), opts.phase_list_deg = [0 90]; end
    if ~isfield(opts,'saveScopes'), opts.saveScopes = true; end

    % ---------- Frequency list ----------
    f_list = logspace(log10(opts.f_start), log10(opts.f_end), opts.n_sample).';


    % ---------- Containers ----------


    fprintf('=== Start frequency sweep ===\n');

    % ---------- Main loop ----------
    assignin('base','f_start',    opts.f_start);
    assignin('base','f_end',      opts.f_end);
    assignin('base','n_sample',   opts.n_sample);
    assignin('base','settle_time', opts.settle_time);
    assignin('base','cycles_n',   opts.cycles_n);
    assignin('base','submag',     opts.submag);
    assignin('base','supmag',     opts.supmag);
    assignin('base','P',          opts.P);
    assignin('base','Q',          opts.Q);
    assignin('base','V0',         opts.V0);
    assignin('base','start_time',         opts.start_time);

    % ---------- Boost ----------
    mdl = bdroot;
    set_param(mdl, ...
      'SaveOutput','off', ...        
      'SaveTime','off', ...
      'ReturnWorkspaceOutputs','off', ...
      'SignalLogging','off');             

    Simulink.sdi.clear;                  % clear SDI 



    for r = 1:2
        assignin('base','harmonics_deg', opts.phase_list_deg(r));
        fprintf('  Simulating full sweep, phase = %d deg ... \n', opts.phase_list_deg(r));
        prevW = warning; warning('off','all');
        cleanup = onCleanup(@() warning(prevW));
        simOut = sim(opts.model, ...
            'StopTime', 'inf', ...
            'SaveOutput','on', ...
            'ReturnWorkspaceOutputs','on');
        fprintf("done.\n");

        % Get data from workspace
        ts = simOut.get(opts.scopeVar);
        t = ts.Time(:);           
        X = ts.Data;          
        vd = X(:,1); vq = X(:,2); id = X(:,3); iq = X(:,4); f = X(:,5);
        Sc_run{r} = struct('t',t,'vd',vd,'vq',vq,'id',id,'iq',iq,'f',f);
        if opts.saveScopes
            DATA_DIR = fullfile(pwd, 'Frequency_scanning_data');
            if ~exist(DATA_DIR, 'dir'), mkdir(DATA_DIR); end
            
            % dot->P
            num2s = @(x) regexprep(sprintf('%.6g', x), '\.', 'p');
            
            % file name (operating points)
            baseName = sprintf('P%s_Q%s_V%s_%s-%sHz', ...
                num2s(opts.P), num2s(opts.Q), num2s(opts.V0), ...
                num2s(opts.f_start), num2s(opts.f_end));
            
            % if file exist, using _01, _02 ...
            fname = [baseName '.mat'];
            fpath = fullfile(DATA_DIR, fname);
            k = 1;
            while exist(fpath, 'file')
                fname = sprintf('%s_%02d.mat', baseName, k);
                fpath = fullfile(DATA_DIR, fname);
                k = k + 1;
            end
            
            % save
            Sc = Sc_run{r};
            meta = struct('P',opts.P,'Q',opts.Q,'V0',opts.V0, ...
                          'f_start',opts.f_start,'f_end',opts.f_end, ...
                          'phase_deg',opts.phase_list_deg(r));
            save(fpath, 'Sc', 'meta');  
        end
    end



    % 3) estimate Ydq for each frequency segment
    [Y11, Y12, Y21, Y22] = identify_Ydq_from_fullscan( ...
    Sc_run{1}, Sc_run{2}, f_list);
    fprintf('=== Sweep finished. ===\n');

    % ---------- Save ----------
    Y_results.f_list = f_list;
    Y_results.Y11 = Y11; Y_results.Y12 = Y12;
    Y_results.Y21 = Y21; Y_results.Y22 = Y22;
end




