function resultados = montecarlo_maniobra_f(sigma_a_normal, sigma_a_maniobra, alpha, PFA)
% MONTECARLO con filtro Kalman con detección de maniobra

addpath(genpath(pwd));

%% 1) Parámetros
N = 200;             
T = 4;               

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

%% 3) Simulación Monte Carlo
erroresAcumulados(N) = struct('longitudinal',[],'transversal',[],'velocidad',[],'rumbo',[],'tiempo',[]);
for i = 1:N
    radar(1).Tini=rand(1,1)*radar(1).Tr; 
    target = real_measurement(target_ideal, radar, true, true, false, 0, 0, projection);
    estimacion = kalman_maniobra(target(1), T, sigma_a_normal, sigma_a_maniobra, alpha, PFA);
    trkEstimada.posStereo = estimacion.pos;
    trkEstimada.velocidad = estimacion.vel_mod;
    trkEstimada.rumbo = estimacion.rumbo;
    trkEstimada.tiempo = target(1).measure(:,2);
    trkEstimada.vel = estimacion.vel; 
    errores = calcularErrores(track(1), trkEstimada);
    erroresAcumulados(i) = errores;
end

%% 4) Análisis 
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


%% 5) Segmentación tramos + transiciones
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

%% 6) Tabla resumen RMS
for i = 1:length(tipos_completos)
    tipo = tipos_completos{i};
    t0 = t_inis(i);
    t1 = t_fins(i);
    dur = t1 - t0;
    idx = find(tiempo >= t0 & tiempo < t1);

    if tipo == "uniforme" || tipo == "giro" || tipo == "acelerado"
        L = limites_tramos(); lim = L.(tipo);
    elseif endsWith(tipo, "_1")
        base = extractBefore(tipo, "_1");
        [lim, ~] = limites_transicion(base, 0);
    elseif endsWith(tipo, "_2")
        base = extractBefore(tipo, "_2");
        [lim, ~] = limites_transicion(base, 999);
    else
        [lim, ~] = limites_transicion(tipo, dur);
    end

    rmsL = sqrt(mean(errLong(idx)));
    rmsT = sqrt(mean(errTrans(idx)));
    rmsV = sqrt(mean(errVel(idx).^2));
    rmsR = sqrt(mean(errRumbo(idx).^2));
    tipo_disp = erase(tipo, ["_1", "_2"]);
end
% RMS instantáneo
%% RMS instantáneo y % de incumplimiento por métrica
ventana = 1;
errLong_RMS = sqrt(movmean(errLong, ventana));
errTrans_RMS = sqrt(movmean(errTrans, ventana));
errVel_RMS = sqrt(movmean(errVel.^2, ventana));
errRumbo_RMS = sqrt(movmean(errRumbo.^2, ventana));

% Inicializar contadores
total_puntos = 0;
fallos_long = 0;
fallos_trans = 0;
fallos_vel = 0;
fallos_rumbo = 0;

for i = 1:length(tipos_completos)
    tipo = tipos_completos{i};
    t0 = t_inis(i); t1 = t_fins(i);
    idx = find(tiempo >= t0 & tiempo <= t1);
    total_puntos = total_puntos + length(idx);

    if tipo == "uniforme" || tipo == "giro" || tipo == "acelerado"
        L = limites_tramos(); lim = L.(tipo);
    elseif endsWith(tipo, "_1")
        base = extractBefore(tipo, "_1");
        [lim, ~] = limites_transicion(base, 0);
    elseif endsWith(tipo, "_2")
        base = extractBefore(tipo, "_2");
        [lim, ~] = limites_transicion(base, 999);
    else
        [lim, ~] = limites_transicion(tipo, t1 - t0);
    end

    fallos_long  = fallos_long  + sum(errLong_RMS(idx) > lim.long);
    fallos_trans = fallos_trans + sum(errTrans_RMS(idx) > lim.trans);
    fallos_vel   = fallos_vel   + sum(errVel_RMS(idx) > lim.vel);
    fallos_rumbo = fallos_rumbo + sum(errRumbo_RMS(idx) > lim.rumbo);
end

% Calcular % de incumplimiento por métrica
p_long  = 100 * fallos_long  / total_puntos;
p_trans = 100 * fallos_trans / total_puntos;
p_vel   = 100 * fallos_vel   / total_puntos;
p_rumbo = 100 * fallos_rumbo / total_puntos;

% Guardar resultados finales
resultados.rms_total = mean([mean(errLong_RMS), mean(errTrans_RMS), mean(errVel_RMS), mean(errRumbo_RMS)]);
resultados.porc_incumplimiento = mean([p_long, p_trans, p_vel, p_rumbo]);
resultados.incumplimiento = struct('long', p_long, 'trans', p_trans, 'vel', p_vel, 'rumbo', p_rumbo);
resultados.params = struct('sigma_n', sigma_a_normal, 'sigma_m', sigma_a_maniobra, 'alpha', alpha, 'PFA', PFA);