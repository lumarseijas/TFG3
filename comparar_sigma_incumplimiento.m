
%clear; close all; clc;
addpath(genpath(pwd));

sigmas = [0.1 0.25 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10];  % valores a probar
T = 4;              % Tiempo de muestreo radar [s]
N = 200;            % Número de simulaciones Monte Carlo

% Generar trayectoria base una sola vez
[track, radar, projection] = generarTrayectoria();
target_ideal = ideal_measurement(track, radar, projection);

% Preparar segmentación
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

for s = 1:length(sigmas)
    sigma_a = sigmas(s);
    erroresAcumulados(N) = struct('longitudinal',[],'transversal',[],'velocidad',[],'rumbo',[],'tiempo',[]);

    for i = 1:N
        target = real_measurement(target_ideal, radar, true, true, false, 0, 0, projection);
        estimacion = kalman_cv(target(1), T, sigma_a);
        trkEstimada.posStereo = estimacion.pos;
        trkEstimada.velocidad = estimacion.vel_mod;
        trkEstimada.rumbo = estimacion.rumbo;
        trkEstimada.tiempo = target(1).measure(:,2);
        errores = calcularErrores(track(1), trkEstimada);
        erroresAcumulados(i) = errores;
    end

    % Usar primera simulación para errores RMS por instante
    errores = erroresAcumulados(1);
    tiempo = errores.tiempo;
    errLong_RMS = sqrt(movmean(errores.longitudinal.^2, 1));
    errTrans_RMS = sqrt(movmean(errores.transversal.^2, 1));
    errVel_RMS = sqrt(movmean(errores.velocidad.^2, 1));
    errRumbo_RMS = sqrt(movmean(errores.rumbo.^2, 1));

    % Recalcular todos los segmentos
    tipos_completos = {};
    t_inis = [];
    t_fins = [];

    for i = 1:length(tipos_tramos)
        tipos_completos{end+1} = tipos_tramos(i);
        t_inis(end+1) = tramos_tiempos(i);
        t_fins(end+1) = tramos_tiempos(i+1);

        if i < length(tipos_tramos)
            tipo_trans = tipos_tramos(i) + "_" + tipos_tramos(i+1);
            t_trans_ini = tramos_tiempos(i+1);
            idx_start = find(tiempo >= t_trans_ini, 1);
            dur = NaN;
            for k = idx_start:(length(tiempo)-5)
                if std(errRumbo(k:k+4)) < 1.5
                    dur = tiempo(k+4) - t_trans_ini;
                    break;
                end
            end
            if isnan(dur), dur = tiempo(end) - t_trans_ini; end
            tipos_completos{end+1} = tipo_trans;
            t_inis(end+1) = t_trans_ini;
            t_fins(end+1) = t_trans_ini + dur;
        end
    end

    % Acumuladores de incumplimiento
    incumpl_long = 0; incumpl_trans = 0; incumpl_vel = 0; incumpl_rumbo = 0;
    total_puntos = 0;

    for i = 1:length(tipos_completos)
        tipo = tipos_completos{i};
        t0 = t_inis(i);
        t1 = t_fins(i);
        dur = t1 - t0;
        idx = find(tiempo >= t0 & tiempo <= t1);
        total_puntos = total_puntos + length(idx);

        if tipo == "uniforme" || tipo == "giro" || tipo == "acelerado"
            L = limites_tramos();
            lim = L.(tipo);
        else
            lim = limites_transicion(tipo, dur);
        end

        incumpl_long = incumpl_long + sum(errLong_RMS(idx) > lim.long);
        incumpl_trans = incumpl_trans + sum(errTrans_RMS(idx) > lim.trans);
        incumpl_vel = incumpl_vel + sum(errVel_RMS(idx) > lim.vel);
        incumpl_rumbo = incumpl_rumbo + sum(errRumbo_RMS(idx) > lim.rumbo);
    end

    % Guardar resultados
    resultados = [resultados; sigma_a, ...
        100*incumpl_long/total_puntos, ...
        100*incumpl_trans/total_puntos, ...
        100*incumpl_vel/total_puntos, ...
        100*incumpl_rumbo/total_puntos];
end

% Mostrar tabla
fprintf('\n--- COMPARACIÓN DE INCUMPLIMIENTO PARA DISTINTOS σ_a ---\n');
fprintf('%8s %10s %10s %10s %10s\n', 'σ_a', 'Long(%)', 'Trans(%)', 'Vel(%)', 'Rumbo(%)');
for i = 1:size(resultados,1)
    fprintf('%8.2f %10.1f %10.1f %10.1f %10.1f\n', resultados(i,:));
end
% Calcular media total de incumplimientos por sigma
media_incumpl = mean(resultados(:,2:5), 2);

% Buscar el mínimo
[~, idx_best] = min(media_incumpl);
mejor_sigma = resultados(idx_best,1);
mejor_media = media_incumpl(idx_best);

fprintf('\\n>> El mejor valor de σₐ es %.2f con un incumplimiento medio total del %.2f%%\\n', mejor_sigma, mejor_media);
