% SIMULACIÓN MONTE CARLO CON KALMAN_CV
%clear; close all; clc;
addpath(genpath(pwd)); 

% Número de simulaciones Monte Carlo
N = 200;

% Parámetros del filtro
T = 4;              % Tiempo de muestreo radar [s]
sigma_a = 0.5;      % Desviación típica aceleración [m/s^2]

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
    errores = calcularErrores(track(1), trkEstimada);
    erroresAcumulados(i) = errores;
end

% Usar solo la primera ejecución para análisis detallado
errores = erroresAcumulados(1);
tiempo = errores.tiempo;
errLong = errores.longitudinal;
errTrans = errores.transversal;
errVel = errores.velocidad;
errRumbo = errores.rumbo;

% Mostrar duración y errores por tramos
fprintf('\n--- ANÁLISIS POR TRAMOS ---\n');
Ltramos = limites_tramos();
for i = 1:size(tramos,1)
    t_ini = tramos_tiempos(i);
    t_fin = tramos_tiempos(i+1);
    dur = t_fin - t_ini;
    idx = find(tiempo >= t_ini & tiempo < t_fin);
    rmsL = sqrt(mean(errLong(idx).^2));
    rmsT = sqrt(mean(errTrans(idx).^2));
    rmsV = sqrt(mean(errVel(idx).^2));
    rmsR = sqrt(mean(errRumbo(idx).^2));
    limites = Ltramos.(tipos_tramos(i));
    fprintf("Tramo %d (%s): Duración %.1f s | RMS Long: %.2f/%.0f m, Trans: %.2f/%.0f m, Vel: %.2f/%.1f m/s, Rumbo: %.2f/%.1f°\n", ...
        i, tipos_tramos(i), dur, rmsL, limites.long, rmsT, limites.trans, rmsV, limites.vel, rmsR, limites.rumbo);
end

fprintf('\n--- ANÁLISIS POR TRANSICIONES ---\n');
for i = 1:(size(tramos,1)-1)
    t_ini = tramos_tiempos(i+1);
    tipo1 = tipos_tramos(i);
    tipo2 = tipos_tramos(i+1);
    trans_key = tipo1 + "_" + tipo2;

    % Buscar cuándo se estabiliza la transición (con rumbo estable)
    idx_start = find(tiempo >= t_ini, 1);
    dur = NaN;
    for k = idx_start:(length(tiempo)-5)
        if std(errRumbo(k:k+4)) < 1.5
            dur = tiempo(k+4) - t_ini;
            break;
        end
    end
    if isnan(dur)
        dur = tiempo(end) - t_ini;
    end
    idx = find(tiempo >= t_ini & tiempo < t_ini + dur);
    rmsL = sqrt(mean(errLong(idx).^2));
    rmsT = sqrt(mean(errTrans(idx).^2));
    rmsV = sqrt(mean(errVel(idx).^2));
    rmsR = sqrt(mean(errRumbo(idx).^2));
    limites = limites_transicion(trans_key, dur);
    fprintf("Transición %d (%s -> %s): Duración %.1f s | RMS Long: %.2f/%.0f m, Trans: %.2f/%.0f m, Vel: %.2f/%.1f m/s, Rumbo: %.2f/%.1f°\n", ...
        i, tipo1, tipo2, dur, rmsL, limites.long, rmsT, limites.trans, rmsV, limites.vel, rmsR, limites.rumbo);
end

% Cálculo RMS en ventana móvil (por instante)
ventana = 1;  % 1 muestra = 4 s
errLong_RMS = sqrt(movmean(errLong.^2, ventana));
errTrans_RMS = sqrt(movmean(errTrans.^2, ventana));
errVel_RMS = sqrt(movmean(errVel.^2, ventana));
errRumbo_RMS = sqrt(movmean(errRumbo.^2, ventana));

% GRÁFICAS con RMS instantáneo y líneas de tramos
figure;
subplot(2,2,1); hold on; plot(tiempo, errLong_RMS, 'r'); ylabel('Longitudinal RMS [m]'); title('Longitudinal RMS'); grid on;
subplot(2,2,2); hold on; plot(tiempo, errTrans_RMS, 'r'); ylabel('Transversal RMS [m]'); title('Transversal RMS'); grid on;
subplot(2,2,3); hold on; plot(tiempo, errRumbo_RMS, 'r'); ylabel('Rumbo RMS [°]'); xlabel('Tiempo [s]'); title('Rumbo RMS'); grid on;
subplot(2,2,4); hold on; plot(tiempo, errVel_RMS, 'r'); ylabel('Velocidad RMS [m/s]'); xlabel('Tiempo [s]'); title('Velocidad RMS'); grid on;

ax = gobjects(4,1);
subplot(2,2,1); ax(1) = gca;
subplot(2,2,2); ax(2) = gca;
subplot(2,2,3); ax(3) = gca;
subplot(2,2,4); ax(4) = gca;

% Pintar líneas de separación de tramos
for t = tramos_tiempos(2:end-1)
    for k = 1:4
        xline(ax(k), t, 'k--');
    end
end

% Crear tipos reales: tramos + transiciones
tipos_completos = {};
t_inis = [];
t_fins = [];

for i = 1:length(tipos_tramos)
    % Tramo i
    tipos_completos{end+1} = tipos_tramos(i);
    t_inis(end+1) = tramos_tiempos(i);
    t_fins(end+1) = tramos_tiempos(i+1);

    % Si hay transición con el siguiente
    if i < length(tipos_tramos)
        tipo_trans = tipos_tramos(i) + "_" + tipos_tramos(i+1);
        t_trans_ini = tramos_tiempos(i+1);

        % Duración efectiva detectada
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

% Añadir máscaras
dibujar_eurocontrol(ax, tiempo, tipos_completos, t_inis, t_fins);


sgtitle(['Simulación Monte Carlo con \sigma_a = ', num2str(sigma_a)]);

fprintf('\n--- PORCENTAJE DE INCUMPLIMIENTO EUROCONTROL ---\n');
fprintf('%-20s %6s %8s %8s %8s %8s\n', 'Segmento', 'Dur(s)', 'Long(%)', 'Trans(%)', 'Vel(%)', 'Rumbo(%)');

% Calcular tramos y transiciones (como antes)
tipos_completos = {};
t_inis = [];
t_fins = [];

for i = 1:length(tipos_tramos)
    % Tramo
    tipos_completos{end+1} = tipos_tramos(i);
    t_inis(end+1) = tramos_tiempos(i);
    t_fins(end+1) = tramos_tiempos(i+1);

    % Transición
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

% Calcular y mostrar por segmento
for i = 1:length(tipos_completos)
    tipo = tipos_completos{i};
    t0 = t_inis(i);
    t1 = t_fins(i);
    dur = t1 - t0;
    idx = find(tiempo >= t0 & tiempo <= t1);

    if tipo == "uniforme" || tipo == "giro" || tipo == "acelerado"
        L = limites_tramos();
        lim = L.(tipo);
    else
        lim = limites_transicion(tipo, dur);
    end

    % % de muestras que incumplen
    pLong = mean(errLong_RMS(idx) > lim.long)*100;
    pTrans = mean(errTrans_RMS(idx) > lim.trans)*100;
    pVel = mean(errVel_RMS(idx) > lim.vel)*100;
    pRumbo = mean(errRumbo_RMS(idx) > lim.rumbo)*100;

    fprintf('%-20s %6.1f %8.1f %8.1f %8.1f %8.1f\n', ...
        tipo, dur, pLong, pTrans, pVel, pRumbo);
end
