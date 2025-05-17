% MONTECARLO con filtro Kalman con detección de maniobra
%clear; close all; clc;
addpath(genpath(pwd));

%% 1) Parámetros
N = 200;             % Número de simulaciones
T = 4;               % Tiempo de muestreo radar

% Parámetros del filtro adaptativo
sigma_a_normal   = 0.001;
sigma_a_maniobra = 10;
alpha            = 0.2;
PFA              = 0.05;

%% 2) Trayectoria ideal
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
    target = real_measurement(target_ideal, radar, true, true, false, 0, 0, projection);
    estimacion = kalman_maniobra(target(1), T, sigma_a_normal, sigma_a_maniobra, alpha, PFA);
    trkEstimada.posStereo = estimacion.pos;
    trkEstimada.velocidad = estimacion.vel_mod;
    trkEstimada.rumbo = estimacion.rumbo;
    trkEstimada.tiempo = target(1).measure(:,2);
    errores = calcularErrores(track(1), trkEstimada);
    erroresAcumulados(i) = errores;
end

% Extraer vectores
t = trkEstimada.tiempo(:);  % Tiempos de la estimación
vi = interp1(track(1).tiempo, track(1).velocidad, t, 'linear', 'extrap');  % Velocidad ideal interpolada
ve = trkEstimada.velocidad(:);  % Velocidad estimada
err = ve - vi;  % Error

% Mostrar los resultados en formato tabla
fprintf('   Tiempo (s)   |  Vel. Ideal (m/s)  |  Vel. Estimada (m/s)  |  Error (m/s)\n');
fprintf('--------------------------------------------------------------------------\n');
for i = 1:20  % Puedes cambiar el 20 por más si quieres ver más líneas
    fprintf('%10.3f     |     %10.3f     |     %10.3f     |   %8.3f\n', t(i), vi(i), ve(i), err(i));
end
%% 4) Análisis con primera ejecución (como referencia gráfica)
errores = erroresAcumulados(1);
tiempo = errores.tiempo;
errLong = errores.longitudinal;
errTrans = errores.transversal;
errVel = errores.velocidad;
errRumbo = errores.rumbo;

% RMS por instante (ventana 1 muestra)
errLong_RMS = sqrt(movmean(errLong.^2, 1));
errTrans_RMS = sqrt(movmean(errTrans.^2, 1));
errVel_RMS = sqrt(movmean(errVel.^2, 1));
errRumbo_RMS = sqrt(movmean(errRumbo.^2, 1));

% Crear tipos completos (tramos + transiciones)
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
        tipos_completos{end+1} = tipo_trans;
        t_inis(end+1) = t_trans_ini;
        t_fins(end+1) = t_trans_ini + dur;
    end
end

%% 5) Porcentaje de incumplimiento EUROCONTROL
fprintf('\n--- FILTRO CON MANIOBRA ---\n');
fprintf('σa normal: %.2f, σa maniobra: %.2f, α: %.2f, PFA: %.3f\n', ...
    sigma_a_normal, sigma_a_maniobra, alpha, PFA);
fprintf('\n%-20s %6s %8s %8s %8s %8s\n', ...
    'Segmento', 'Dur(s)', 'Long(%)', 'Trans(%)', 'Vel(%)', 'Rumbo(%)');

for i = 1:length(tipos_completos)
    tipo = tipos_completos{i};
    t0 = t_inis(i); t1 = t_fins(i);
    dur = t1 - t0;
    idx = find(tiempo >= t0 & tiempo <= t1);

    if tipo == "uniforme" || tipo == "giro" || tipo == "acelerado"
        L = limites_tramos(); lim = L.(tipo);
    else
        lim = limites_transicion(tipo, dur);
    end

    pLong  = mean(errLong_RMS(idx)  > lim.long) * 100;
    pTrans = mean(errTrans_RMS(idx) > lim.trans) * 100;
    pVel   = mean(errVel_RMS(idx)   > lim.vel) * 100;
    pRumbo = mean(errRumbo_RMS(idx) > lim.rumbo) * 100;

    fprintf('%-20s %6.1f %8.1f %8.1f %8.1f %8.1f\n', tipo, dur, pLong, pTrans, pVel, pRumbo);
end
%% 6) Dibujar RMS + bandas EUROCONTROL
figure;
subplot(2,2,1); hold on; plot(tiempo, errLong_RMS, 'r'); ylabel('Longitudinal RMS [m]'); title('Longitudinal RMS'); grid on;
subplot(2,2,2); hold on; plot(tiempo, errTrans_RMS, 'r'); ylabel('Transversal RMS [m]'); title('Transversal RMS'); grid on;
subplot(2,2,3); hold on; plot(tiempo, errRumbo_RMS, 'r'); ylabel('Rumbo RMS [°]'); xlabel('Tiempo [s]'); title('Rumbo RMS'); grid on;
subplot(2,2,4); hold on; plot(tiempo, errVel_RMS, 'r'); ylabel('Velocidad RMS [m/s]'); xlabel('Tiempo [s]'); title('Velocidad RMS'); grid on;

% Obtener ejes
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

% Dibujar bandas verdes de límites
dibujar_eurocontrol(ax, tiempo, tipos_completos, t_inis, t_fins);

sgtitle(sprintf('Filtro Kalman con maniobra (\\sigma_n = %.2f, \\sigma_m = %.2f, \\alpha = %.2f fa = %.2f)', ...
    sigma_a_normal, sigma_a_maniobra, alpha, PFA));

