function dibujar_eurocontrol(ax, tiempo, tipos, t_inis, t_fins)
% Dibuja los límites EUROCONTROL en las 4 subgráficas

for i = 1:length(tipos)
    t0 = t_inis(i);
    t1 = t_fins(i);
    tipo = tipos{i};

    if tipo == "uniforme" || tipo == "giro" || tipo == "acelerado"
        L = limites_tramos();
        lim = L.(tipo);
    else
        dur = t1 - t0;
        lim = limites_transicion(tipo, dur);
    end

    fill_area(ax(1), t0, t1, lim.long);
    fill_area(ax(2), t0, t1, lim.trans);
    fill_area(ax(3), t0, t1, lim.rumbo);
    fill_area(ax(4), t0, t1, lim.vel);
end
end


function fill_area(ax, t0, t1, ymax)
    axes(ax);
    fill([t0 t1 t1 t0], [0 0 ymax ymax], [0.7 1.0 0.7], ...
         'EdgeColor','none','FaceAlpha',0.4);
end
