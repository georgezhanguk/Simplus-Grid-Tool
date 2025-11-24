clear;clc;close all;
% DESCRIPTION
%   Run a frequency-scan on the Simulink model to identify the small-signal
%   dq-admittance matrix Y(jω). The script sets simulation options, calls
%   run_freq_sweep(opts), collects Y11~Y22 over f_list, and plots magnitude
%   and phase.
%
% AUTHOR
%   Yuming Wang

% --- Use the model in current folder ---
thisFile = mfilename('fullpath');
scriptDir = fileparts(thisFile);


%% --- ↓↓↓↓↓↓ Model name here (include Harmonic Injection Subsystem) ↓↓↓↓↓↓ ---
mdlName = 'Frequency_scanning_2024a';
%mdlName = 'Hybrid_Dual_Infinite_Bus_2';

%% --- ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑---


mdlPath = fullfile(scriptDir, [mdlName '.slx']);

open_system(mdlPath); 
opts.model = mdlName;
%% Scanning setting
opts.scopeVar = 'simout';
opts.f_start = 2; opts.f_end = 3e3; opts.n_sample = 75;
opts.settle_time = 0.1; opts.submag = 0.005; opts.supmag = 0.005; opts.cycles_n = 5;
opts.P = 0.5; opts.Q = 0.1; opts.V0 = 0.85; opts.start_time = 0.5;

% Run simulink
Yres = run_freq_sweep(opts);
f_list = Yres.f_list;
Y11 = Yres.Y11; Y12 = Yres.Y12;
Y21 = Yres.Y21; Y22 = Yres.Y22;

% Plot
% ---- Magnitude ----
figure('Name','|Y_dq(j\omega)|');
subplot(2,2,1);
loglog(f_list, abs(Y11), '-'); grid on;
xlabel('Probe frequency (Hz)'); ylabel('|Y_{dd}| (A/V)');
title('Magnitude |Y_{dd}|');

subplot(2,2,2);
loglog(f_list, abs(Y12), '-'); grid on;
xlabel('Probe frequency (Hz)'); ylabel('|Y_{dq}| (A/V)');
title('Magnitude |Y_{dq}|');

subplot(2,2,3);
loglog(f_list, abs(Y21), '-'); grid on;
xlabel('Probe frequency (Hz)'); ylabel('|Y_{qd}| (A/V)');
title('Magnitude |Y_{qd}|');

subplot(2,2,4);
loglog(f_list, abs(Y22), '-'); grid on;
xlabel('Probe frequency (Hz)'); ylabel('|Y_{qq}| (A/V)');
title('Magnitude |Y_{qq}|');

% ---- Phase ----
figure('Name','∠Y_dq(j\omega)');
subplot(2,2,1);
semilogx(f_list, rad2deg(angle(Y11)), '-'); grid on;
xlabel('Probe frequency (Hz)'); ylabel('Phase (deg)');
title('Phase ∠Y_{dd}');

subplot(2,2,2);
semilogx(f_list, rad2deg(angle(Y12)), '-'); grid on;
xlabel('Probe frequency (Hz)'); ylabel('Phase (deg)');
title('Phase ∠Y_{dq}');

subplot(2,2,3);
semilogx(f_list, rad2deg(angle(Y21)), '-'); grid on;
xlabel('Probe frequency (Hz)'); ylabel('Phase (deg)');
title('Phase ∠Y_{qd}');

subplot(2,2,4);
semilogx(f_list, rad2deg(angle(Y22)), '-'); grid on;
xlabel('Probe frequency (Hz)'); ylabel('Phase (deg)');
title('Phase ∠Y_{qq}');

bdclose(mdlName);   
