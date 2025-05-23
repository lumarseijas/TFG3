addpath(genpath(pwd));
% --- 1. Generar una única trayectoria con maniobra ---
[track, radar, projection] = generarTrayectoriaAcel();
Tmedida = radar(1).Tr;  % Tiempo entre medidas de radar (4 segundos)

% --- 2. Visualizar la trayectoria real (posición XY) ---
figure;
plot(track(1).posStereo(:,1)/1e3, track(1).posStereo(:,2)/1e3, 'b-');
xlabel('X [km]');
ylabel('Y [km]');
title('Trayectoria real con aceleración');
grid on;
axis equal;

% --- 3. Visualizar velocidad y rumbo reales ---
Tmuestreo = track(1).tiempo(2) - track(1).tiempo(1);  % tiempo de muestreo fino
vx_real_full = gradient(track(1).posStereo(:,1), Tmuestreo);
vy_real_full = gradient(track(1).posStereo(:,2), Tmuestreo);

velocidad_full = sqrt(vx_real_full.^2 + vy_real_full.^2);
rumbo_full = atan2(vy_real_full, vx_real_full) * 180/pi;  % en grados

figure;
subplot(2,1,1);
plot(track(1).tiempo, velocidad_full);
xlabel('Tiempo [s]');
ylabel('Velocidad [m/s]');
title('Velocidad real vs Tiempo');
grid on;

subplot(2,1,2);
plot(track(1).tiempo, rumbo_full);
xlabel('Tiempo [s]');
ylabel('Rumbo [°]');
title('Rumbo real vs Tiempo');
grid on;
