% Script param_opt.m
% Optimización de parámetros para filtro Kalman con detección de maniobra

%clc; clear;

% Valores a probar
sigma_n_vals = [0.04, 0.05, 0.06, 0.07, 0.08];
sigma_m_vals = [10, 11, 12, 13, 14, 15, 17, 19, 20];
alpha_vals = [0.4, 0.5, 0.6, 0.7];
PFA_vals = [0.02, 0.05, 0.07, 0.1];


% Inicializar resultados
resultados = [];

% Contador de combinaciones
total_comb = length(sigma_n_vals) * length(sigma_m_vals) * length(alpha_vals) * length(PFA_vals);
contador = 0;

% Bucle doble: barrido de todos los valores
for sigma_n = sigma_n_vals
    for sigma_m = sigma_m_vals
        for alpha = alpha_vals
            for PFA = PFA_vals
                contador = contador + 1;
                fprintf('\n[%d/%d] Ejecutando con σₐ_normal=%.2f, σₐ_maniobra=%.2f, α=%.2f, PFA=%.0e\n', ...
                        contador, total_comb, sigma_n, sigma_m, alpha, PFA);

                try
                    res = montecarlo_maniobra_f(sigma_n, sigma_m, alpha, PFA);
                    resultados(end+1,:) = [sigma_n, sigma_m, alpha, PFA, ...
                                           res.rms_total, res.porc_incumplimiento];
                catch ME
                    warning('Error en combinación [%d/%d]: %s', contador, total_comb, ME.message);
                    resultados(end+1,:) = [sigma_n, sigma_m, alpha, PFA, NaN, NaN];
                end
            end
        end
    end
end
tabla = array2table(resultados, ...
    'VariableNames', {'sigma_n', 'sigma_m', 'alpha', 'PFA', 'RMS_total', 'Porc_incumplimiento'});

tabla_ordenada = sortrows(tabla, {'Porc_incumplimiento','RMS_total'});

%% Mostrar todos los resultados por pantalla
fprintf('\n Resultados completos por combinación:\n');
fprintf('| %6s | %6s | %5s | %7s | %10s | %10s |\n', ...
        'σₐ_n', 'σₐ_m', 'α', 'PFA', 'RMS total', '% Incumpl.');
fprintf('|--------|--------|------|---------|------------|-------------|\n');

for i = 1:height(tabla_ordenada)
    fprintf('| %6.2f | %6.1f | %4.2f | %7.1e | %10.2f | %10.2f |\n', ...
        tabla_ordenada.sigma_n(i), tabla_ordenada.sigma_m(i), ...
        tabla_ordenada.alpha(i), tabla_ordenada.PFA(i), ...
        tabla_ordenada.RMS_total(i), tabla_ordenada.Porc_incumplimiento(i));
end

%% Mostrar la MEJOR combinación
mejor = tabla_ordenada(1,:);

fprintf('\n MEJOR COMBINACIÓN ENCONTRADA:\n');
fprintf('σₐ_normal   = %.2f\n', mejor.sigma_n);
fprintf('σₐ_maniobra = %.1f\n', mejor.sigma_m);
fprintf('α           = %.2f\n', mejor.alpha);
fprintf('PFA         = %.1e\n', mejor.PFA);
fprintf('RMS total   = %.2f\n', mejor.RMS_total);
fprintf('%% Incumpl.  = %.2f%%\n', mejor.Porc_incumplimiento);

%% Analizar los mejores valores individuales por parámetro
fprintf('\n Análisis por parámetro:\n');

% Mejor valor medio para sigma_n
medias_sn = varfun(@mean, tabla_ordenada, 'InputVariables', 'Porc_incumplimiento', ...
    'GroupingVariables', 'sigma_n');
[~, idx_sn] = min(medias_sn.mean_Porc_incumplimiento);
fprintf('- Mejor σₐ_normal medio = %.2f (con %.2f%% incumplimiento medio)\n', ...
    medias_sn.sigma_n(idx_sn), medias_sn.mean_Porc_incumplimiento(idx_sn));

% Mejor valor medio para sigma_m
medias_sm = varfun(@mean, tabla_ordenada, 'InputVariables', 'Porc_incumplimiento', ...
    'GroupingVariables', 'sigma_m');
[~, idx_sm] = min(medias_sm.mean_Porc_incumplimiento);
fprintf('- Mejor σₐ_maniobra medio = %.1f (con %.2f%% incumplimiento medio)\n', ...
    medias_sm.sigma_m(idx_sm), medias_sm.mean_Porc_incumplimiento(idx_sm));

% Mejor valor medio para alpha
medias_alpha = varfun(@mean, tabla_ordenada, 'InputVariables', 'Porc_incumplimiento', ...
    'GroupingVariables', 'alpha');
[~, idx_alpha] = min(medias_alpha.mean_Porc_incumplimiento);
fprintf('- Mejor α medio = %.2f (con %.2f%% incumplimiento medio)\n', ...
    medias_alpha.alpha(idx_alpha), medias_alpha.mean_Porc_incumplimiento(idx_alpha));

% Mejor valor medio para PFA
medias_pfa = varfun(@mean, tabla_ordenada, 'InputVariables', 'Porc_incumplimiento', ...
    'GroupingVariables', 'PFA');
[~, idx_pfa] = min(medias_pfa.mean_Porc_incumplimiento);
fprintf('- Mejor PFA medio = %.1e (con %.2f%% incumplimiento medio)\n', ...
    medias_pfa.PFA(idx_pfa), medias_pfa.mean_Porc_incumplimiento(idx_pfa));

%% Detalle de la mejor combinación
mejor_resultado = montecarlo_maniobra_f(mejor.sigma_n, mejor.sigma_m, mejor.alpha, mejor.PFA); 
fprintf('\n Detalle de incumplimiento por métrica (mejor combinación):\n');
fprintf('- Longitudinal:   %.2f %%\n', mejor_resultado.incumplimiento.long);
fprintf('- Transversal:    %.2f %%\n', mejor_resultado.incumplimiento.trans);
fprintf('- Velocidad:      %.2f %%\n', mejor_resultado.incumplimiento.vel);
fprintf('- Rumbo:          %.2f %%\n', mejor_resultado.incumplimiento.rumbo);