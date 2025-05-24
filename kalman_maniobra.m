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
x0 = medidas(1,:)';
v0 = (medidas(2,:) - medidas(1,:))' / T;
x_est = [x0; v0];

S1 = covs(:,:,1); S2 = covs(:,:,2);
P_pos     = S1;
P_vel     = (S1 + S2) / T^2;
P_pos_vel = S1 / T;
P0 = [P_pos,     P_pos_vel;
      P_pos_vel', P_vel];
P = P0;

% 5) Detector de maniobra (suavizado exponencial de energía del residuo)
M = 2;
Neq = (1 + alpha) / (1 - alpha) * M;
gamma = chi2inv(1 - PFA, Neq);
Z = Neq;

% 6) Variables de control de maniobra
modo_maniobra = false;
contador_maniobra = 0;
duracion_maniobra = round(20 / T);  % mantener durante ~20s tras detección

% 7) Reservar espacio para salidas
x_out     = zeros(N, 4);
vel_mod   = zeros(N, 1);
rumbo_out = zeros(N, 1);
x_out(1,:) = x_est';

% 8) Bucle de filtrado Kalman adaptativo
for k = 2:N
    z = medidas(k,:)';
    R = covs(:,:,k);

    % 8.1) Selección dinámica de Q
    sigma_a = sigma_a_nominal;

    if Z > gamma
        modo_maniobra = true;
        contador_maniobra = duracion_maniobra;
        %fprintf(">> MANIOBRA detectada en índice k = %d (Z = %.2f > γ = %.2f)\n", k, Z, gamma);
    end

    if modo_maniobra
        sigma_a = sigma_a_maniobra;
        contador_maniobra = contador_maniobra - 1;
        if contador_maniobra <= 0
            modo_maniobra = false;
        end
    end

    % 8.2) Ruido de proceso
    G = [T^2/2  0;
         0      T^2/2;
         T      0;
         0      T];
    Q = (sigma_a.^2) * (G * G');

    % 8.3) Predicción
    x_pred = F * x_est;
    P_pred = F * P * F' + Q;

    % 8.4) Innovación y detector
    innov = z - H * x_pred;
    S     = H * P_pred * H' + R;
    nu    = innov' * (S \ innov);
    Z     = alpha * Z + (1 - alpha) * nu;

    % 8.5) Corrección
    K     = P_pred * H' / S;
    x_est = x_pred + K * innov;
    P     = (eye(4) - K * H) * P_pred;

    % 8.6) Guardar resultados
    x_out(k,:) = x_est';
    vx = x_est(3); vy = x_est(4);
    vel_mod(k) = sqrt(vx^2 + vy^2);
    rumbo_out(k) = mod(atan2(vx, vy) * 180 / pi, 360);
end

% 9) Salida final
estimacion.pos      = x_out(:,1:2);
estimacion.vel      = x_out(:,3:4);
estimacion.vel_mod  = vel_mod;
estimacion.rumbo    = rumbo_out;

end
