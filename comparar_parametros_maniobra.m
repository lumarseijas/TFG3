addpath(genpath(pwd));

%% Parámetros del barrido
sigmas_normal   = [0.01 0.03];
sigmas_maniobra = [3.0 4.0];
alfas           = [0.2 0.3];
pfa_vals        = [0.015 0.02];

T = 4;
N = 200;

% Trayectoria base
[track, radar, projection] = generarTrayectoria();
target_ideal = ideal_measurement(track, radar, projection);

% Segmentación
tramos = track(1).tramos;
tramos_tiempos = track(1).tramos_tiempos;
tipos_tramos = strings(size(tramos,1),1);
for i = 1:size(tramos,1)
    if tramos(i,2) ~= 0
        tipos_tramos(i) = "giro";
    elseif tramos(i,1) ~= 0
        tipos_tramos(i) = "acelerado";
    else
        tipos_tramos(i) = "uniforme";
    end
end

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

                % Inicializar acumuladores
                errLong = 0; errTrans = 0; errVel = 0; errRumbo = 0;
                total_puntos = 0;

                % Tiempo base
                tiempo_ref = [];

                for j = 1:N
                    target = real_measurement(target_ideal, radar, true, true, false, 0, 0, projection);
                    est = kalman_maniobra(target(1), T, sigma_n, sigma_m, alpha, PFA);
                    trkEstimada.posStereo = est.pos;
                    trkEstimada.velocidad = est.vel_mod;
                    trkEstimada.rumbo = est.rumbo;
                    trkEstimada.tiempo = target(1).measure(:,2);
                    trkEstimada.vel = est.vel;
                    err = calcularErrores(track(1), trkEstimada);
                    errAcumulados(i) = err;
                end
                    tiempo_ref = errAcumulados(1).tiempo;
                    errLong = zeros(size(tiempo_ref));
                    errTrans = zeros(size(tiempo_ref));
                    errVel = zeros(size(tiempo_ref));
                    errRumbo = zeros(size(tiempo_ref));
                    
                for i = 1:N
                    errLong = errLong + errAcumulados(i).longitudinal;
                    errTrans = errTrans + errAcumulados(i).transversal;
                    errVel = errVel + errAcumulados(i).velocidad;
                    errRumbo = errRumbo + errAcumulados(i).rumbo;
                end

                % Medias
                errLong = errLong / N;
                errTrans = errTrans / N;
                errVel = errVel / N;
                errRumbo = errRumbo / N;

                % RMS
                errLongRMS = sqrt(movmean(errLong.^2, 1));
                errTransRMS = sqrt(movmean(errTrans.^2, 1));
                errVelRMS = sqrt(movmean(errVel.^2, 1));
                errRumboRMS = sqrt(movmean(errRumbo.^2, 1));

                % Segmentación temporal
                tipos_completos = {};
                t_inis = []; t_fins = [];

                for i = 1:length(tipos_tramos)
                    tipos_completos{end+1} = tipos_tramos(i);
                    t_inis(end+1) = tramos_tiempos(i);
                    t_fins(end+1) = tramos_tiempos(i+1);

                    if i < length(tipos_tramos)
                        tipo_trans = tipos_tramos(i) + "_" + tipos_tramos(i+1);
                        t_trans_ini = tramos_tiempos(i+1);
                        [~, umbral] = limites_transicion(tipo_trans, 0);
                        tipos_completos{end+1} = tipo_trans + "_1";
                        t_inis(end+1) = t_trans_ini;
                        t_fins(end+1) = t_trans_ini + umbral;

                        tipos_completos{end+1} = tipo_trans + "_2";
                        t_inis(end+1) = t_trans_ini + umbral;
                        t_fins(end+1) = tramos_tiempos(i+2);
                    end
                end

                incumpl_total = zeros(1,4);

                for i = 1:length(tipos_completos)
                    tipo = tipos_completos{i};
                    t0 = t_inis(i); t1 = t_fins(i);
                    idx = find(tiempo_ref >= t0 & tiempo_ref <= t1);
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

                    incumpl_total(1) = incumpl_total(1) + sum(errLongRMS(idx) > lim.long);
                    incumpl_total(2) = incumpl_total(2) + sum(errTransRMS(idx) > lim.trans);
                    incumpl_total(3) = incumpl_total(3) + sum(errVelRMS(idx) > lim.vel);
                    incumpl_total(4) = incumpl_total(4) + sum(errRumboRMS(idx) > lim.rumbo);
                end

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

%% Mostrar mejor combinación
[~, idx_best] = min(resultados(:,end));
mejor = resultados(idx_best,:);

fprintf('\n>> Mejor combinación:\n');
fprintf('σₐ_normal = %.2f, σₐ_maniobra = %.2f, α = %.2f, PFA = %.3f\n', ...
    mejor(1), mejor(2), mejor(3), mejor(4));
fprintf('Incumplimiento medio: %.2f%% (Long %.1f%%, Trans %.1f%%, Vel %.1f%%, Rumbo %.1f%%)\n', ...
    mejor(end), mejor(5), mejor(6), mejor(7), mejor(8));
