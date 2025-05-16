% SIMULACIÓN MONTE CARLO CON KALMAN_CV
%clear; close all; clc;

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

% Cálculo RMS en ventana móvil (por instante)
ventana = 1;  % 1 muestra cada 4s (T muestreo)
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

% Añadir líneas verticales de cambio de tramo en todos los subplots
for t = tramos_tiempos(2:end-1)  % sin primera ni última
    subplot(2,2,1); xline(t, 'k--');
    subplot(2,2,2); xline(t, 'k--');
    subplot(2,2,3); xline(t, 'k--');
    subplot(2,2,4); xline(t, 'k--');
end

sgtitle(['Simulación Monte Carlo con \sigma_a = ', num2str(sigma_a)]);
