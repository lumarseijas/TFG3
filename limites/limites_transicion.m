function L = limites_transicion(tipo, duracion)
% Devuelve estructura con los límites EUROCONTROL según transición y duración

% Valores por defecto (laxos)
L = struct('long', Inf, 'trans', Inf, 'vel', Inf, 'rumbo', Inf);

switch tipo
    case "uniforme_giro"
        L.long = 140;
        L.trans = 230;
        L.vel = 6;
        L.rumbo = 17;
        if duracion > 24
            L.rumbo = 14.5;
            L.trans = 215;
        end

    case "giro_uniforme"
        L.long = 100;
        L.trans = 100;
        L.vel = 4;
        L.rumbo = 6;
        if duracion > 65
            L.long = 71;
            L.trans = 78;
            L.vel = 1.1;
            L.rumbo = 1.6;
        end

    case "uniforme_acelerado"
        L.long = 310;
        L.trans = 120;
        L.vel = 26;
        L.rumbo = 6;
        if duracion > 50
            L.long = 211;
            L.vel = 18.6;
        end
        if duracion > 60 
            L.trans = 72;
        end
        if duracion > 65 
            L.rumbo = 1.75;
        end
    otherwise
        error('mal');
end

end
