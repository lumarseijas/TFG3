function estimacion = kalman_maniobra(target, T, sigma_a_nominal, sigma_a_maniobra, alpha, PFA)
% Filtro Kalman CV con detección de maniobra y adaptación dinámica de Q
%
% INPUTS:
%   target: estructura de medidas del radar
%   T: tiempo de muestreo (s)
%   sigma_a_nominal: σₐ en condiciones normales [m/s²]
%   sigma_a_maniobra: σₐ durante maniobras [m/s²]
%   alpha: factor de suavizado exponencial
%   PFA: probabilidad de falsa alarma 
%
% OUTPUT:
%   estimacion: estructura con .pos, .vel, .vel_mod, .rumbo

% 1) Medidas y covarianzas
medidas = target.measure(:,13:14);   % coordenadas estereográficas x, y
covs = target.mcov;                  % matriz de covarianza 2x2xN
N = size(medidas, 1);

% 2) Matriz de transición (F) 
F = [1 0 T 0;
     0 1 0 T;
     0 0 1 0;
     0 0 0 1];

% 3) Matriz de observación (H) 
H = [1 0 0 0;
     0 1 0 0];

% 4) Inicialización del estado
x0 = medidas(1,:)';                                % posición inicial
v0 = (medidas(2,:) - medidas(1,:))' / T;           % velocidad inicial
x_est = [x0; v0];                                   % estado inicial

S1 = covs(:,:,1); S2 = covs(:,:,2);
P_pos     = S1;
P_vel     = (S1 + S2) / T^2;
P_pos_vel = S1 / T;
P0 = [P_pos,     P_pos_vel;
      P_pos_vel', P_vel];
P = P0;

% 5) Inicialización del detector de maniobra 
M = 2;  % dimensión de la medida
Neq = (1 + alpha) / (1 - alpha) * M;
gamma = chi2inv(1 - PFA, Neq);
Z = Neq;  % valor inicial esperado

% 6) Reservar espacio para salidas
x_out     = zeros(N, 4);
vel_mod   = zeros(N, 1);
rumbo_out = zeros(N, 1);
x_out(1,:) = x_est';

% 7) Bucle de filtrado Kalman adaptativo
for k = 2:N
    z = medidas(k,:)';
    R = covs(:,:,k);

    % 7.1) Selección dinámica de Q según Z
    if Z > gamma
        sigma_a = sigma_a_maniobra;
    else
        sigma_a = sigma_a_nominal;
    end

    % 7.2) Matriz de ruido de proceso (Q)
    G = [T^2/2  0;
         0      T^2/2;
         T      0;
         0      T];
    Q = (sigma_a^2) * (G * G');

    % 7.3) Predicción
    x_pred = F * x_est;
    P_pred = F * P * F' + Q;

    % 7.4) Innovación
    innov = z - H * x_pred;
    S     = H * P_pred * H' + R;
    nu    = innov' * (S \ innov);  % energía del residuo
    Z     = alpha * Z + (1 - alpha) * nu;  % detector exponencial

    % 7.5) Actualización
    K     = P_pred * H' / S;
    x_est = x_pred + K * innov;
    P     = (eye(4) - K * H) * P_pred;

    % 7.6) Guardar resultados
    x_out(k,:) = x_est';
    vx = x_est(3); vy = x_est(4);
    vel_mod(k) = norm([vx vy]);
    rumbo_out(k) = mod(atan2(vx, vy) * 180 / pi, 360);
end

% 8) Salida final
estimacion.pos      = x_out(:,1:2);
estimacion.vel      = x_out(:,3:4);
estimacion.vel_mod  = vel_mod;
estimacion.rumbo    = rumbo_out;

end
