%clear; clc;
addpath(genpath(pwd));

sigmas_m = [10, 15, 20];
alphas = [0.5, 0.3, 0.2];
PFA_vals = [0.01, 0.05, 0.1];

resultados = [];

for s = 1:length(sigmas_m)
    for a = 1:length(alphas)
        for p = 1:length(PFA_vals)

            sigma_m = sigmas_m(s);
            alpha = alphas(a);
            PFA = PFA_vals(p);

            [errores, tiempo] = montecarlo_maniobra(sigma_m, alpha, PFA);

            % Índices del tramo de giro (ajusta si cambias tiempos)
            t0 = 240; t1 = 338;
            tiempos = errores.tiempo(:);  % usar el tiempo correcto del vector de errores
            idx = tiempos >= t0 & tiempos <= t1;
            if length(errores.longitudinal) ~= length(errores.tiempo)
                error('¡Dimensiones no coinciden entre errores y tiempo!');
            end



            % RMS por componente
            rmsL = rms(errores.longitudinal(idx));
            rmsT = rms(errores.transversal(idx));
            rmsV = rms(errores.velocidad(idx));
            rmsR = rms(errores.rumbo(idx));
            totalRMS = sqrt(rmsL^2 + rmsT^2 + rmsV^2 + rmsR^2);

            resultados(end+1,:) = [sigma_m, alpha, PFA, rmsL, rmsT, rmsV, rmsR, totalRMS];

            fprintf('σₘ = %.1f, α = %.2f, PFA = %.3f → RMS(L:%.1f, T:%.1f, V:%.1f, R:%.1f) → Total: %.1f\n', ...
                sigma_m, alpha, PFA, rmsL, rmsT, rmsV, rmsR, totalRMS);
        end
    end
end

% Tabla ordenada
T = array2table(resultados, ...
    'VariableNames', {'sigma_m', 'alpha', 'PFA', 'RMS_Long', 'RMS_Trans', 'RMS_Vel', 'RMS_Rumbo', 'RMS_Total'});

T = sortrows(T, 'RMS_Total');
disp(T);
