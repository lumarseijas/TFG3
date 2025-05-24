function [L, umbral] = limites_transicion(tipo, duracion)

% Normalizar tipos con sufijo "_1" o "_2"
if endsWith(tipo, "_1") || endsWith(tipo, "_2")
    tipo = extractBefore(tipo, strlength(tipo)-1);  % elimina "_1" o "_2"
end

% Devuelve estructura con los límites EUROCONTROL según transición y duración
% También devuelve el umbral a partir del cual cambian los valores

% Valores por defecto (laxos)
L = struct('long', Inf, 'trans', Inf, 'vel', Inf, 'rumbo', Inf);
umbral = 0;

switch tipo
    case "uniforme_giro"
        umbral = 24;
        if duracion > umbral
            L.long = 140;
            L.trans = 215;
            L.vel = 6;
            L.rumbo = 14.5;
        else
            L.long = 140;
            L.trans = 230;
            L.vel = 6;
            L.rumbo = 17;
        end

    case "giro_uniforme"
        umbral = 65;
        if duracion > umbral
            L.long = 71;
            L.trans = 78;
            L.vel = 1.1;
            L.rumbo = 1.6;
        else
            L.long = 100;
            L.trans = 100;
            L.vel = 4;
            L.rumbo = 6;
        end

    case "uniforme_acelerado"
        umbral = 50;  % para el long y vel
        if duracion > 65
            L.rumbo = 1.75;
        else
            L.rumbo = 6;
        end
        if duracion > 60
            L.trans = 72;
        else
            L.trans = 120;
        end
        if duracion > 50
            L.long = 211;
            L.vel = 18.6;
        else
            L.long = 310;
            L.vel = 26;
        end
    case "acelerado_uniforme"
        umbral = 0;
        if duracion > umbral
            L.long = 180;
            L.trans = 60;
            L.vel = 17;
            L.rumbo = 1.5;
        end
    otherwise
        error('Tipo de transición no reconocido');
end
end