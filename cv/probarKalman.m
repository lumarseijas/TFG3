addpath(genpath(pwd));  % Añade todas las subcarpetas del proyecto al path

[track, radar, projection] = generarTrayectoria();

target_ideal = ideal_measurement(track, radar, projection);
target_real  = real_measurement(target_ideal, radar, 1, 1, 0, 0, 0, projection);

T = radar(1).Tr;  % tiempo de muestreo (4 s)
sigma_a = 2.5;    % o cualquier valor que estés probando

estimacion = kalman_cv(target_real(1), T, sigma_a);

% === PLOT DE TRAZAS EN XY ===

% 1. Trayectoria ideal (track)
x_real = track(1).posStereo(:,1);
y_real = track(1).posStereo(:,2);

% 2. Medidas radar con ruido
x_meas = target_real(1).measure(:,13);
y_meas = target_real(1).measure(:,14);

% 3. Estimación Kalman
x_kalman = estimacion.pos(:,1);
y_kalman = estimacion.pos(:,2);

% plots
figure; hold on; grid on; axis equal;
plot(x_real, y_real, 'k-', 'LineWidth', 2);         % Trayectoria ideal
plot(x_meas, y_meas, 'rx');                         % Medidas del radar
plot(x_kalman, y_kalman, 'b-', 'LineWidth', 2);     % Kalman estimado

legend('Trayectoria ideal', 'Medidas radar', 'Kalman estimado');
xlabel('X [m]');
ylabel('Y [m]');
title(['Comparación de trayectorias - \sigma_a = ', num2str(sigma_a), ' m/s^2']);