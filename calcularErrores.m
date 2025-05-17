function errores = calcularErrores(trkIdeal, trkEstimada)
% CALCULARERRORES Calcula los errores longitudinal, transversal, de velocidad y rumbo
% entre la trayectoria estimada y la ideal.
%
% Entradas:
%   - trkIdeal: estructura con campos .posStereo, .velocidad, .rumbo, .tiempo
%   - trkEstimada: igual estructura que trkIdeal
%
% Salida:
%   - errores: estructura con campos longitud, trans, vel, rumbo, tiempo

% Interpolamos los valores ideales a los tiempos de la estimación
t = trkEstimada.tiempo(:);
xi = interp1(trkIdeal.tiempo, trkIdeal.posStereo(:,1), t, 'linear', 'extrap');
yi = interp1(trkIdeal.tiempo, trkIdeal.posStereo(:,2), t, 'linear', 'extrap');
vi = interp1(trkIdeal.tiempo, trkIdeal.velocidad, t, 'linear', 'extrap'); %vel_real
ri = interp1(trkIdeal.tiempo, trkIdeal.rumbo, t, 'linear', 'extrap');

% Posición y velocidad estimadas
xe = trkEstimada.posStereo(:,1);
ye = trkEstimada.posStereo(:,2);
%ve = trkEstimada.velocidad;
vx = trkEstimada.vel(:,1);
vy = trkEstimada.vel(:,2);
ve = sqrt(vx.^2 + vy.^2);

re = trkEstimada.rumbo;

% Vector tangente y normal a la trayectoria ideal
v_dir = [cosd(ri), sind(ri)];
v_norm = [-sind(ri), cosd(ri)];

% Vector de error de posición
delta_pos = [xe - xi, ye - yi];

% Proyección sobre dirección tangente (error longitudinal)
err_long = sum(delta_pos .* v_dir, 2);

% Proyección sobre dirección normal (error transversal)
err_trans = sum(delta_pos .* v_norm, 2);

% Error en velocidad
err_vel = ve - vi;

% Error en rumbo (convertimos a radianes, usamos angdiff, y devolvemos en grados)
err_rumbo = rad2deg(angdiff(deg2rad(ri), deg2rad(re)));

% Salida
errores.longitudinal = err_long;
errores.transversal = err_trans;
errores.velocidad = err_vel;
errores.rumbo = err_rumbo;
errores.tiempo = t;

end
