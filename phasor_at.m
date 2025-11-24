function [X, stats] = phasor_at(t, x, f0)
% PHASOR_FFT  Compute complex phasor at frequency f0 (uniform sampling).
%
%   X = phasor_fft(t, x, f0)
%

    t = t(:); 
    x = x(:);
    N = numel(x);
    dt = t(2) - t(1);
    fs = 1/dt;

    X = (2/N) * sum(x .* exp(-1j*2*pi*f0*t));

    if nargout > 1
        T = N*dt;               
        df = 1/T;               
        f_bin = round(f0/df)*df;% 最近的 FFT bin
        stats.N  = N;
        stats.dt = dt;
        stats.fs = fs;
        stats.df = df;
        stats.f_bin = f_bin;
        stats.bin_aligned = abs(f_bin - f0) < 1e-12;
    end
end


% function [X, stats] = phasor_at(t, x, f0)
% % PHASOR_AT  Complex phasor at f0 using least-squares on possibly
% % non-uniform samples.
% % Model: x(t) ≈ A*cos(ωt) + B*sin(ωt) + C
% % Then complex phasor (peak) is:  X = A - j B
% % Returns:
% %   X     complex peak phasor
% %   stats struct (A,B,C,resnorm)
% 
%     t = t(:); x = x(:);
%     omega = 2*pi*f0;
% 
%     % Design matrix: [cos(ωt)  sin(ωt)  1]
%     Phi = [cos(omega*t), sin(omega*t), ones(size(t))];
% 
%     % Least squares
%     theta = Phi \ x;             % [A; B; C]
%     A = theta(1); B = theta(2); C = theta(3); %#ok<NASGU>
%     X = A - 1j*B;
% 
%     if nargout > 1
%         stats.A = A; stats.B = B; stats.C = C;
%         stats.resnorm = norm(Phi*theta - x);
%     end
% end