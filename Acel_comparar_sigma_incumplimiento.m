addpath(genpath(pwd));

sigmas = [0.01 0.03 0.05 0.1 0.3 0.5 0.8 1.0 2.0 3.0 5.0 7.0 10.0 12.0 15.0];
T = 4;
N = 200;

[track, radar, projection] = generarTrayectoriaAcel();
target_ideal = ideal_measurement(track, radar, projection);

tramos = track(1).tramos;
tramos_tiempos = track(1).tramos_tiempos;
tipos_tramos = strings(size(tramos,1),1);
for i = 1:size(tramos,1)
    if tramos(i,2) ~= 0
        tipos_tramos(i) = "giro";
    elseif tramos(i,1) ~= 0
        tipos_tramos(i) = "acelerado";
    else
        tipos_tramos(i) = "uniforme";
    end
end

resultadosGlobales = [];
mejores_sigma = struct();

for s = 1:length(sigmas)
    sigma_a = sigmas(s);
    erroresAcumulados(N) = struct('longitudinal',[],'transversal',[],'velocidad',[],'rumbo',[],'tiempo',[]);

    for i = 1:N
        radar(1).Tini = rand(1)*radar(1).Tr;
        target = real_measurement(target_ideal, radar, true, true, false, 0, 0, projection);
        estimacion = kalman_cv(target(1), T, sigma_a);
        trkEstimada.posStereo = estimacion.pos;
        trkEstimada.velocidad = estimacion.vel_mod;
        trkEstimada.rumbo = estimacion.rumbo;
        trkEstimada.tiempo = target(1).measure(:,2);
        trkEstimada.vel = estimacion.vel;
        errores = calcularErrores(track(1), trkEstimada);
        erroresAcumulados(i) = errores;
    end

    tiempo = erroresAcumulados(1).tiempo;
    errLong = zeros(size(tiempo)); errTrans = errLong; errVel = errLong; errRumbo = errLong;
    for i = 1:N
        errLong = errLong + erroresAcumulados(i).longitudinal;
        errTrans = errTrans + erroresAcumulados(i).transversal;
        errVel = errVel + erroresAcumulados(i).velocidad;
        errRumbo = errRumbo + erroresAcumulados(i).rumbo;
    end
    errLong = errLong / N; errTrans = errTrans / N; errVel = errVel / N; errRumbo = errRumbo / N;
    errLong_RMS = sqrt(movmean(errLong, 1));
    errTrans_RMS = sqrt(movmean(errTrans, 1));
    errVel_RMS = sqrt(movmean(errVel.^2, 1));
    errRumbo_RMS = sqrt(movmean(errRumbo.^2, 1));

    tipos_completos = {}; t_inis = []; t_fins = [];
    for i = 1:length(tipos_tramos)
        tipo_base = tipos_tramos(i);
        if tipo_base == "uniforme" && (i == 1 || i == length(tipos_tramos))
            tipo = tipo_base + "(" + num2str(i) + ")";
        else
            tipo = tipo_base;
        end
        tipos_completos{end+1} = tipo;
        t_inis(end+1) = tramos_tiempos(i);
        t_fins(end+1) = tramos_tiempos(i+1);

        if i < length(tipos_tramos)
            tipo_trans = tipos_tramos(i) + " → " + tipos_tramos(i+1);
            t_trans_ini = tramos_tiempos(i+1);
            idx_start = find(tiempo >= t_trans_ini, 1);
            dur = NaN;
            for k = idx_start:(length(tiempo)-5)
                if std(errRumbo(k:k+4)) < 1.5
                    dur = tiempo(k+4) - t_trans_ini;
                    break;
                end
            end
            if isnan(dur), dur = tiempo(end) - t_trans_ini; end
            dur_max = tramos_tiempos(i+2) - t_trans_ini;
            dur = min(dur, dur_max);
            [~, umbral] = limites_transicion(tipos_tramos(i) + "_" + tipos_tramos(i+1), 0);
            tipos_completos{end+1} = tipo_trans;
            t_inis(end+1) = t_trans_ini;
            t_fins(end+1) = t_trans_ini + dur;
        end
    end

    datos_segmentos = zeros(length(tipos_completos), 6);
    segmentos_labels = strings(length(tipos_completos), 1);

    for i = 1:length(tipos_completos)
        tipo = tipos_completos{i}; t0 = t_inis(i); t1 = t_fins(i);
        idx = find(tiempo >= t0 & tiempo <= t1);
        dur = t1 - t0;

        tipo_limpio = tipo;
        if contains(tipo, "(")
            tipo_limpio = "uniforme";
        elseif contains(tipo, " → ")
            tipo_limpio = strrep(tipo, " → ", "_");
        end

        if ismember(tipo_limpio, ["uniforme", "giro", "acelerado"])
            L = limites_tramos(); lim = L.(tipo_limpio);
        else
            try
                [lim, ~] = limites_transicion(tipo_limpio, dur);
            catch
                warning("Tipo no reconocido en limites_transicion: %s", tipo_limpio);
                continue;
            end
        end

        datos_segmentos(i,:) = [dur,
            mean(errLong_RMS(idx) > lim.long)*100,
            mean(errTrans_RMS(idx) > lim.trans)*100,
            mean(errVel_RMS(idx) > lim.vel)*100,
            mean(errRumbo_RMS(idx) > lim.rumbo)*100,
            sigma_a];
        segmentos_labels(i) = tipo;
    end

    tabla_sigma = array2table(datos_segmentos, 'VariableNames', {'Duracion', '%Long', '%Trans', '%Vel', '%Rumbo', 'Sigma'});
    tabla_sigma.Segmento = segmentos_labels;
    resultadosGlobales = [resultadosGlobales; tabla_sigma];
end

segmentos = unique(resultadosGlobales.Segmento);
mejores_sigma_tabla = table('Size',[0 2],'VariableTypes',{'string','double'},'VariableNames',{'Segmento','SigmaOptima'});

for i = 1:length(segmentos)
    seg = segmentos(i);
    subtabla = resultadosGlobales(resultadosGlobales.Segmento == seg, :);
    subtabla.MediaIncumpl = mean(subtabla{:,2:5},2);
    [~, idxBest] = min(subtabla.MediaIncumpl);
    mejores_sigma_tabla = [mejores_sigma_tabla; {seg, subtabla.Sigma(idxBest)}];
end

% Mostrar resultados finales
fprintf('\nSegmento\t\t\tSigma óptima\n');
for i = 1:height(mejores_sigma_tabla)
    fprintf('%-20s\t%.4f\n', mejores_sigma_tabla.Segmento(i), mejores_sigma_tabla.SigmaOptima(i));
end

% Sigma global
mediaPorSigma = varfun(@mean, resultadosGlobales, 'InputVariables', {'%Long','%Trans','%Vel','%Rumbo'}, 'GroupingVariables','Sigma');
mediaPorSigma.IncumplMedio = mean(mediaPorSigma{:,3:6}, 2);
[~, idxGlobal] = min(mediaPorSigma.IncumplMedio);
mejorSigmaGlobal = mediaPorSigma.Sigma(idxGlobal);
disp("\nMejor sigma global:");
disp(mejorSigmaGlobal);
