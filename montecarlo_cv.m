% SIMULACIÓN MONTE CARLO CON KALMAN_CV
%clear; close all; clc;
addpath(genpath(pwd)); 

% Número de simulaciones Monte Carlo
N = 200;

% Parámetros del filtro
T = 4;              % Tiempo de muestreo radar [s]
sigma_a = 1;      % Desviación típica aceleración [m/s^2]

% Generar trayectoria ideal
[track, radar, projection] = generarTrayectoria();
target_ideal = ideal_measurement(track, radar, projection);

% Preparar segmentación de tramos y transiciones
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

% Inicializar acumuladores de errores
erroresAcumulados(N) = struct('longitudinal',[],'transversal',[],'velocidad',[],'rumbo',[],'tiempo',[]);

% MONTE CARLO
for i = 1:N
    target = real_measurement(target_ideal, radar, true, true, false, 0, 0, projection);
    estimacion = kalman_cv(target(1), T, sigma_a);
    trkEstimada.posStereo = estimacion.pos;
    trkEstimada.velocidad = estimacion.vel_mod;
    trkEstimada.rumbo = estimacion.rumbo;
    trkEstimada.tiempo = target(1).measure(:,2);
    trkEstimada.vel = estimacion.vel;
    errores = calcularErrores(track(1), trkEstimada);
    erroresAcumulados(i) = errores;
end

errores = erroresAcumulados(1);
tiempo = errores.tiempo;
errLong = errores.longitudinal;
errTrans = errores.transversal;
errVel = errores.velocidad;
errRumbo = errores.rumbo;

% Calcular tipos_completos, t_inis, t_fins con división por umbral
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

fprintf('## Análisis por Tramos y Transiciones (σₐ = %.1f)\n\n', sigma_a);
fprintf('| # | Tipo              | Duración (s) | Long (RMS / Max) | Trans (RMS / Max) | Vel (RMS / Max) | Rumbo (RMS / Max) |\n');
fprintf('|----|-------------------|--------------|-------------------|--------------------|------------------|--------------------|\n');


for i = 1:length(tipos_completos)
    tipo = tipos_completos{i};
    t0 = t_inis(i);
    t1 = t_fins(i);
    dur = t1 - t0;
    idx = find(tiempo >= t0 & tiempo < t1);

    % Obtener límites correctos
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

    % Calcular RMS
    rmsL = sqrt(mean(errLong(idx).^2));
    rmsT = sqrt(mean(errTrans(idx).^2));
    rmsV = sqrt(mean(errVel(idx).^2));
    rmsR = sqrt(mean(errRumbo(idx).^2));

    tipo_display = erase(tipo, ["_1", "_2"]);

    % Imprimir en modo tabla
    fprintf('| %2d | %-17s | %10.1f | %7.2f / %-5.0f   | %7.2f / %-5.0f    | %6.2f / %-4.1f    | %6.2f / %-4.1f    |\n', ...
        i, tipo_display, dur, ...
        rmsL, lim.long, ...
        rmsT, lim.trans, ...
        rmsV, lim.vel, ...
        rmsR, lim.rumbo);

end


% RMS instantáneo
ventana = 1;
errLong_RMS = sqrt(movmean(errLong.^2, ventana));
errTrans_RMS = sqrt(movmean(errTrans.^2, ventana));
errVel_RMS = sqrt(movmean(errVel.^2, ventana));
errRumbo_RMS = sqrt(movmean(errRumbo.^2, ventana));

% Gráficas
figure;
subplot(2,2,1); hold on; plot(tiempo, errLong_RMS, 'r'); ylabel('Longitudinal RMS [m]'); title('Longitudinal RMS'); grid on;
subplot(2,2,2); hold on; plot(tiempo, errTrans_RMS, 'r'); ylabel('Transversal RMS [m]'); title('Transversal RMS'); grid on;
subplot(2,2,3); hold on; plot(tiempo, errRumbo_RMS, 'r'); ylabel('Rumbo RMS [°]'); xlabel('Tiempo [s]'); title('Rumbo RMS'); grid on;
subplot(2,2,4); hold on; plot(tiempo, errVel_RMS, 'r'); ylabel('Velocidad RMS [m/s]'); xlabel('Tiempo [s]'); title('Velocidad RMS'); grid on;

ax = gobjects(4,1);
for k = 1:4, ax(k) = subplot(2,2,k); end
for t = tramos_tiempos(2:end-1)
    for k = 1:4
        xline(ax(k), t, 'k--');
    end
end

dibujar_eurocontrol(ax, track(1).tiempo, tipos_completos, t_inis, t_fins);

sgtitle(['Simulación Monte Carlo con \sigma_a = ', num2str(sigma_a)]);

% Mostrar porcentajes de incumplimiento

fprintf('## Porcentaje de Incumplimiento EUROCONTROL (σₐ = %.1f)\n\n', sigma_a);
fprintf('| Segmento           | Duración (s) | Longitud (%%) | Transversal (%%) | Velocidad (%%) | Rumbo (%%) |\n');
fprintf('|--------------------|--------------|----------------|-------------------|----------------|------------|\n');


for i = 1:length(tipos_completos)
    tipo = tipos_completos{i};
    t0 = t_inis(i);
    t1 = t_fins(i);
    dur = t1 - t0;
    idx = find(tiempo >= t0 & tiempo <= t1);

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

    pLong = mean(errLong_RMS(idx) > lim.long)*100;
    pTrans = mean(errTrans_RMS(idx) > lim.trans)*100;
    pVel = mean(errVel_RMS(idx) > lim.vel)*100;
    pRumbo = mean(errRumbo_RMS(idx) > lim.rumbo)*100;

    fprintf('| %-18s | %10.1f | %12.1f | %15.1f | %13.1f | %10.1f |\n', ...
        tipo, dur, pLong, pTrans, pVel, pRumbo);

end

