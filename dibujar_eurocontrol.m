
function dibujar_eurocontrol(ax, tiempo, tipos, t_inis, t_fins)
% Dibuja los límites EUROCONTROL en 4 subgráficas (ax) usando áreas verdes
% ax: vector de ejes de subplot
% tiempo: vector de tiempo
% tipos: cell array de strings ('uniforme', 'giro', 'uniforme_giro', etc.)
% t_inis, t_fins: vectores con los tiempos de inicio y fin de cada tramo/transición

for i = 1:length(tipos)
    t0 = t_inis(i);
    t1 = t_fins(i);
    tipo = tipos{i};

    % Obtener límites
    if tipo == "uniforme" || tipo == "giro" || tipo == "acelerado"
        L = limites_tramos();
        lim = L.(tipo);
    else
        dur = t1 - t0;
        lim = limites_transicion(tipo, dur);
    end

    % Dibujar área verde en cada subplot
    fill_area(ax(1), t0, t1, lim.long);
    fill_area(ax(2), t0, t1, lim.trans);
    fill_area(ax(3), t0, t1, lim.rumbo);
    fill_area(ax(4), t0, t1, lim.vel);
end
end

function fill_area(ax, t0, t1, ymax)
% Dibuja una banda verde de 0 a ymax entre t0 y t1 en un eje dado
    axes(ax);
    fill([t0 t1 t1 t0], [0 0 ymax ymax], [0.7 1.0 0.7], ...
         'EdgeColor','none','FaceAlpha',0.4);
end
