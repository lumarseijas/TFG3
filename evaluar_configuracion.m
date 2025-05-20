function resultados = evaluar_configuracion(sigma_a_normal, sigma_a_maniobra, alpha, PFA)
% Script para evaluar una configuración de parámetros del filtro con maniobra

addpath(genpath(pwd));

% 1. Parámetros
N = 200;   % Número reducido para prueba rápida
T = 4;

% 2. Trayectoria ideal
[track, radar, projection] = generarTrayectoria();
target_ideal = ideal_measurement(track, radar, projection);

tramos          = track(1).tramos;
tramos_tiempos  = track(1).tramos_tiempos;
tipos_tramos    = strings(size(tramos,1),1);
for i = 1:size(tramos,1)
    if tramos(i,2) ~= 0
        tipos_tramos(i) = "giro";
    elseif tramos(i,1) ~= 0
        tipos_tramos(i) = "acelerado";
    else
        tipos_tramos(i) = "uniforme";
    end
end

% 3. Simulación Monte Carlo
erroresAcumulados(N) = struct('longitudinal',[],'transversal',[],'velocidad',[],'rumbo',[],'tiempo',[]);
for i = 1:N
    target = real_measurement(target_ideal, radar, true, true, false, 0, 0, projection);
    estimacion = kalman_maniobra(target(1), T, sigma_a_normal, sigma_a_maniobra, alpha, PFA);
    trkEstimada.posStereo = estimacion.pos;
    trkEstimada.velocidad = estimacion.vel_mod;
    trkEstimada.rumbo = estimacion.rumbo;
    trkEstimada.tiempo = target(1).measure(:,2);
    trkEstimada.vel = estimacion.vel;
    erroresAcumulados(i) = calcularErrores(track(1), trkEstimada);
end

% 4. Promedios RMS
tiempo = erroresAcumulados(1).tiempo;
errLong = zeros(size(tiempo));
errTrans = zeros(size(tiempo));
errVel = zeros(size(tiempo));
errRumbo = zeros(size(tiempo));

for i = 1:N
    errLong = errLong + erroresAcumulados(i).longitudinal;
    errTrans = errTrans + erroresAcumulados(i).transversal;
    errVel = errVel + erroresAcumulados(i).velocidad;
    errRumbo = errRumbo + erroresAcumulados(i).rumbo;
end

errLong = errLong / N;
errTrans = errTrans / N;
errVel = errVel / N;
errRumbo = errRumbo / N;

% 5. Cálculo de incumplimientos
ventana = 1;
errLong_RMS = sqrt(movmean(errLong.^2, ventana));
errTrans_RMS = sqrt(movmean(errTrans.^2, ventana));
errVel_RMS = sqrt(movmean(errVel.^2, ventana));
errRumbo_RMS = sqrt(movmean(errRumbo.^2, ventana));

% Segmentación
tipos_completos = {};
t_inis = []; t_fins = [];
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
        dur_max = tramos_tiempos(i+2) - t_trans_ini;
        dur = min(dur, dur_max);
        [~, umbral] = limites_transicion(tipo_trans, 0);
        if dur > umbral
            tipos_completos{end+1} = tipo_trans + "_1";
            t_inis(end+1) = t_trans_ini;
            t_fins(end+1) = t_trans_ini + umbral;
            tipos_completos{end+1} = tipo_trans + "_2";
            t_inis(end+1) = t_trans_ini + umbral;
            t_fins(end+1) = t_trans_ini + dur;
        else
            tipos_completos{end+1} = tipo_trans;
            t_inis(end+1) = t_trans_ini;
            t_fins(end+1) = t_trans_ini + dur;
        end
    end
end

% 6. Porcentajes de incumplimiento promedio total
total_idx = tiempo >= t_inis(1) & tiempo <= t_fins(end);
L = limites_tramos();
lim_all = L.uniforme; % Para globalizar, tomamos los límites más exigentes

% Si quieres, también puedes usar el peor caso de todos
lim_all.long = max([L.uniforme.long, L.acelerado.long, L.giro.long]);
lim_all.trans = max([L.uniforme.trans, L.acelerado.trans, L.giro.trans]);
lim_all.vel = max([L.uniforme.vel, L.acelerado.vel, L.giro.vel]);
lim_all.rumbo = max([L.uniforme.rumbo, L.acelerado.rumbo, L.giro.rumbo]);

% Porcentaje de tiempo con errores que superan límite
resultados = struct();
resultados.sigma_a_normal = sigma_a_normal;
resultados.sigma_a_maniobra = sigma_a_maniobra;
resultados.alpha = alpha;
resultados.PFA = PFA;
resultados.pLong = mean(errLong_RMS(total_idx) > lim_all.long)*100;
resultados.pTrans = mean(errTrans_RMS(total_idx) > lim_all.trans)*100;
resultados.pVel = mean(errVel_RMS(total_idx) > lim_all.vel)*100;
resultados.pRumbo = mean(errRumbo_RMS(total_idx) > lim_all.rumbo)*100;

end
