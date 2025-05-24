function estimacion = kalman_cv(target, T, sigma_a)
% Filtro de Kalman CV para seguimiento 2D con medidas reales de radar
%
% INPUTS:
%   target: estructura de medidas (target(j)) de real_measurement
%   T: tiempo de muestreo del radar [s]
%   sigma_a: desviación típica de la aceleración [m/s²]
%
% OUTPUT:
%   estimacion: estructura con campos .pos, .vel, .vel_mod, .rumbo


medidas = target.measure(:,13:14);  % coordenadas estereográficas x, y
covs = target.mcov;                 % matriz de covarianza 2x2xN

N = size(medidas, 1);  % número de medidas

% 1) Matriz de transición (F)
F = [1 0 T 0;
     0 1 0 T;
     0 0 1 0;
     0 0 0 1];

% 2) Matriz de observación (H)
H = [1 0 0 0;
     0 1 0 0];

% 3) Matriz Q (ruido de proceso)
G = [T^2/2 0;
     0 T^2/2;
     T    0;
     0    T];
Q = (sigma_a.^2) * (G * G');

% 4) Estado inicial: posición y velocidad estimada
x0 = medidas(1,:)';  % posición
v0 = (medidas(2,:) - medidas(1,:))' / T;  % velocidad
x_est = [x0; v0];  % estado inicial

% 5) Covarianza inicial del estado
S1 = covs(:,:,1); S2 = covs(:,:,2);
P_pos = S1;
P_vel = (S1 + S2)/(T^2);
P_pos_vel = S1/T;
P0 = [P_pos, P_pos_vel;
      P_pos_vel', P_vel];
P = P0;

% Reservar espacio para las salidas
x_out = zeros(N, 4);
rumbo_out = zeros(N, 1);
vel_mod = zeros(N,1);
x_out(1,:) = x_est';

% 6) Bucle de Kalman
for k = 2:N
    z = medidas(k,:)';
    R = covs(:,:,k);

    % Predicción
    x_pred = F * x_est;
    P_pred = F * P * F' + Q;

    % Actualización
    y = z - H * x_pred;
    S = H * P_pred * H' + R;
    K = P_pred * H' / S;
    x_est = x_pred + K * y;
    P = (eye(4) - K * H) * P_pred;

    % Guardar estimaciones
    x_out(k,:) = x_est';
    vx = x_est(3); vy = x_est(4);
    vel_mod(k) = norm([vx vy]);
    rumbo_out(k) = mod(atan2(vx, vy)*180/pi, 360);  % rumbo en grados
end

% Salida
estimacion.pos = x_out(:,1:2);      % [x, y]
estimacion.vel = x_out(:,3:4);      % [vx, vy]
estimacion.vel_mod = vel_mod;       % |v|
estimacion.rumbo = rumbo_out;       % en grados

end
