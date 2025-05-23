function [track, radar, projection] = generarTrayectoriaAcel()
% FUNCION generarTrayectoria
% Crea un radar, una trayectoria y la proyección estereográfica

%% Datos de la Tierra y proyección estereográfica
geoide = referenceEllipsoid('wgs84', 'meter');

latP = 40.5; % Latitud del centro de proyección
longP = 0.5; % Longitud del centro de proyección
altP = 0;

projection = defaultm('stereo');
origen = [latP longP altP];
projection.origin = origen;
projection.geoid = geoide;
projection = defaultm(projection);

Ts = 0.001; % Tiempo de muestreo de la trayectoria, muy fino (1 ms)

%% Definición del radar
[radar(1).posGeod(1), radar(1).posGeod(2)] = stereo(...
         projection,0,0,'surface','inverse'); %posicion del radar 1 (lat º, lon º, h en m)
radar(1).posGeod(3) = 0; % Altura del radar 0 m
radar(1).id = 1;
radar(1).range = 400e3;
radar(1).resDist = 70;     % Error en distancia (m)- desviacion tipica dist - sigma rho
radar(1).resAzim = 0.08;   % Error en azimut (º)-desviacion tipica acimut - sigma tetha
radar(1).Tr = 4;           % Tiempo de barrido radar (s)
% radar(1).Tini = rand(1)*radar(1).Tr; % Tiempo inicial aleatorio
radar(1).Tini = 0;
radar(1).VelMS = 0;
radar(1).StVel = 0;

%% Trayectoria inicial
% se convierte la posicion inicial del plano estereografico a coordenadas geodesicas

[yini, xini] = stereo(projection, -26.305e3, 150e3+26.305e3, 'surface', 'inverse'); %X,Y iniciales en lat lon
zini = 10e3;    % 10 km de altura
vini = 155;     % velocidad inicial
rini = 135;     % rumbo inicial
%cini = 0;
tramos = [0 0 0 240; 1 0 0 100; 0 0 0 262]; % Acel longitudinal, Acel Transversal, Acel vertical y duracion por tramo
% mio para tener los tramos
track(1).tramos = tramos;
track(1).tramos_tiempos = cumsum([0; tramos(:,4)]);

%% Generación de la trayectoria ideal sobremuestreada
To=0;
[track(1).posGeod, track(1).tiempo, track(1).velocidad, track(1).rumbo, track(1).velascen] = ...
    trayectMia(tramos, [yini xini zini], vini, rini, To, Ts, geoide);

%% Proyección a estereográficas
[radar(1).posStereo(1), radar(1).posStereo(2)] = stereo(...
    projection, radar(1).posGeod(1), radar(1).posGeod(2),'surface','forward');
radar(1).posStereo(3) = radar(1).posGeod(3);

[track(1).posStereo(:,1), track(1).posStereo(:,2)] = stereo(...
    projection, track(1).posGeod(:,1), track(1).posGeod(:,2), 'surface', 'forward');
track(1).posStereo(:,3) = track(1).posGeod(:,3);

%% Medidas del radar

radar(1).Tini=rand(1,1)*radar(1).Tr;  %Aleatorizacion del tiempo inicial del radar
target_ideal = ideal_measurement( track, radar, projection );   %Posición ideal de avistamiento
target_real = real_measurement(target_ideal, radar,1,1,0,0,0,projection);   %GENERACIÓN DE LA MEDIDA CON LOS ERRORES

% plot(target_real.measure(:,13)/1e3,target_real.measure(:,14)/1e3,'+m')

end