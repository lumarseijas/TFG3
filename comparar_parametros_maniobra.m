%clear; clc;
addpath(genpath(pwd));

%% Parámetros del barrido
sigmas_normal   = [0.01 0.03];           % valores bajos, precisos en recta
sigmas_maniobra = [3.0 4.0];       % más agresivos para girar mejor
alfas           = [0.2 0.3];        
pfa_vals        = [0.015 0.02];        


T = 4;             % Tiempo de muestreo radar
N = 200;           % Nº simulaciones Monte Carlo por combinación
M = 2;             % Dimensión de medida (x, y)

% Trayectoria base
[track, radar, projection] = generarTrayectoria();
target_ideal = ideal_measurement(track, radar, projection);

% Segmentación
tramos         = track(1).tramos;
tramos_tiempos = track(1).tramos_tiempos;
tipos_tramos   = strings(size(tramos,1),1);
for i = 1:size(tramos,1)
    if tramos(i,2) ~= 0
        tipos_tramos(i) = "giro";
    elseif tramos(i,1) ~= 0
        tipos_tramos(i) = "acelerado";
    else
        tipos_tramos(i) = "uniforme";
    end
end

% Resultado acumulado
resultados = [];

%% Barrido de combinaciones
for s_n = 1:length(sigmas_normal)
    for s_m = 1:length(sigmas_maniobra)
        for a = 1:length(alfas)
            for p = 1:length(pfa_vals)
                
                sigma_n = sigmas_normal(s_n);
                sigma_m = sigmas_maniobra(s_m);
                alpha   = alfas(a);
                PFA     = pfa_vals(p);

                % Calcular gamma (umbral) dinámico
                Neq = (1 + alpha) / (1 - alpha) * M;
                gamma = chi2inv(1 - PFA, Neq);

                % Inicializar acumuladores
                incumpl_total = zeros(1,4);  % long, trans, vel, rumbo
                total_puntos = 0;

                for i = 1:N
                    target = real_measurement(target_ideal, radar, true, true, false, 0, 0, projection);
                    est = kalman_maniobra(target(1), T, sigma_n, sigma_m, alpha, PFA);
                    trkEstimada.posStereo = est.pos;
                    trkEstimada.velocidad = est.vel_mod;
                    trkEstimada.rumbo = est.rumbo;
                    trkEstimada.vel = est.vel; 
                    trkEstimada.tiempo = target(1).measure(:,2);
                    err = calcularErrores(track(1), trkEstimada);

                    tiempo = err.tiempo;
                    errLong = sqrt(movmean(err.longitudinal.^2, 1));
                    errTrans = sqrt(movmean(err.transversal.^2, 1));
                    errVel = sqrt(movmean(err.velocidad.^2, 1));
                    errRumbo = sqrt(movmean(err.rumbo.^2, 1));

                    % Evaluar segmentos y transiciones
                    tipos_completos = {};
                    t_inis = [];
                    t_fins = [];
                    
                    for j = 1:length(tipos_tramos)
                        tipos_completos{end+1} = tipos_tramos(j);
                        t_inis(end+1) = tramos_tiempos(j);
                        t_fins(end+1) = tramos_tiempos(j+1);
                        
                        if j < length(tipos_tramos)
                            tipo_trans = tipos_tramos(j) + "_" + tipos_tramos(j+1);
                            t_ini = tramos_tiempos(j+1);
                            idx_start = find(tiempo >= t_ini, 1);
                            dur = NaN;
                            for k = idx_start:(length(tiempo)-5)
                                if std(err.rumbo(k:k+4)) < 1.5
                                    dur = tiempo(k+4) - t_ini;
                                    break;
                                end
                            end
                            if isnan(dur)
                                dur = tiempo(end) - t_ini;
                            end
                            dur_max = tramos_tiempos(j+2) - t_ini;
                            dur = min(dur, dur_max);
                    
                            [~, umbral] = limites_transicion(tipo_trans, 0);
                            if dur > umbral
                                tipos_completos{end+1} = tipo_trans + "_1";
                                t_inis(end+1) = t_ini;
                                t_fins(end+1) = t_ini + umbral;
                    
                                tipos_completos{end+1} = tipo_trans + "_2";
                                t_inis(end+1) = t_ini + umbral;
                                t_fins(end+1) = t_ini + dur;
                            else
                                tipos_completos{end+1} = tipo_trans;
                                t_inis(end+1) = t_ini;
                                t_fins(end+1) = t_ini + dur;
                            end
                        end
                    end
                    
                    for j = 1:length(tipos_completos)
                        tipo = tipos_completos{j};
                        t0 = t_inis(j); t1 = t_fins(j);
                        idx = find(tiempo >= t0 & tiempo <= t1);
                        total_puntos = total_puntos + length(idx);
                    
                        if tipo == "uniforme" || tipo == "giro" || tipo == "acelerado"
                            lim = limites_tramos().(tipo);
                        elseif endsWith(tipo, "_1")
                            base = extractBefore(tipo, "_1");
                            [lim, ~] = limites_transicion(base, 0);
                        elseif endsWith(tipo, "_2")
                            base = extractBefore(tipo, "_2");
                            [lim, ~] = limites_transicion(base, 999);
                        else
                            dur = t1 - t0;
                            [lim, ~] = limites_transicion(tipo, dur);
                        end
                    
                        incumpl_total(1) = incumpl_total(1) + sum(errLong(idx) > lim.long);
                        incumpl_total(2) = incumpl_total(2) + sum(errTrans(idx) > lim.trans);
                        incumpl_total(3) = incumpl_total(3) + sum(errVel(idx) > lim.vel);
                        incumpl_total(4) = incumpl_total(4) + sum(errRumbo(idx) > lim.rumbo);
                    end

                end

                % Resultado de esta combinación
                incumpl_percent = 100 * incumpl_total / total_puntos;
                media = mean(incumpl_percent);
                resultados = [resultados;
                    sigma_n, sigma_m, alpha, PFA, incumpl_percent, media];
                fprintf('[%.2f %.2f α=%.2f PFA=%.3f] ⇒ Med %.2f%%\n', ...
                    sigma_n, sigma_m, alpha, PFA, media);
            end
        end
    end
end

%% Buscar mejor combinación
[~, idx_best] = min(resultados(:,end));
mejor = resultados(idx_best,:);

fprintf('\n>> Mejor combinación:\n');
fprintf('σₐ_normal = %.2f, σₐ_maniobra = %.2f, α = %.2f, PFA = %.3f\n', ...
    mejor(1), mejor(2), mejor(3), mejor(4));
fprintf('Incumplimiento medio: %.2f%% (Long %.1f%%, Trans %.1f%%, Vel %.1f%%, Rumbo %.1f%%)\n', ...
    mejor(end), mejor(5), mejor(6), mejor(7), mejor(8));

% Calcular mejores valores individuales
sigmas_n = unique(resultados(:,1));
sigmas_m = unique(resultados(:,2));
alfas = unique(resultados(:,3));
pfas = unique(resultados(:,4));

mejor_sigma_n = NaN;
mejor_sigma_m = NaN;
mejor_alpha = NaN;
mejor_pfa = NaN;

min_med_n = Inf;
min_med_m = Inf;
min_med_a = Inf;
min_med_p = Inf;

% Para cada sigma_n
for s = 1:length(sigmas_n)
    idx = resultados(:,1) == sigmas_n(s);
    media = mean(resultados(idx,end));
    if media < min_med_n
        min_med_n = media;
        mejor_sigma_n = sigmas_n(s);
    end
end

% Para cada sigma_maniobra
for s = 1:length(sigmas_m)
    idx = resultados(:,2) == sigmas_m(s);
    media = mean(resultados(idx,end));
    if media < min_med_m
        min_med_m = media;
        mejor_sigma_m = sigmas_m(s);
    end
end

% Para cada alpha
for a = 1:length(alfas)
    idx = resultados(:,3) == alfas(a);
    media = mean(resultados(idx,end));
    if media < min_med_a
        min_med_a = media;
        mejor_alpha = alfas(a);
    end
end

% Para cada PFA
for p = 1:length(pfas)
    idx = resultados(:,4) == pfas(p);
    media = mean(resultados(idx,end));
    if media < min_med_p
        min_med_p = media;
        mejor_pfa = pfas(p);
    end
end

% Mostrar resultados
fprintf('\n>> Mejores valores individuales:\n');
fprintf('Mejor σₐ_normal   = %.2f (med %.2f%%)\n', mejor_sigma_n, min_med_n);
fprintf('Mejor σₐ_maniobra = %.2f (med %.2f%%)\n', mejor_sigma_m, min_med_m);
fprintf('Mejor α           = %.2f (med %.2f%%)\n', mejor_alpha, min_med_a);
fprintf('Mejor PFA         = %.3f (med %.2f%%)\n', mejor_pfa, min_med_p);
