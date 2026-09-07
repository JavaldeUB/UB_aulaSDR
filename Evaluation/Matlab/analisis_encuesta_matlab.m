%% ANALISIS DE ENCUESTA - poolResults.xlsx
% Script para analizar automáticamente la encuesta de 19 evaluadores.
% Genera:
%   1) Media por ítem
%   2) Media por sección
%   3) Distribución Likert por sección
%   4) Distribución Likert por ítem
%   5) Comparación entre evaluadores
%   6) Radar de las secciones
%   7) Tabla resumen exportada a Excel
%
% Coloca este archivo .m en la misma carpeta que poolResults.xlsx
% y ejecuta el script.

clear; close all; clc;

%% CONFIGURACIÓN

archivo = fullfile(fileparts(pwd), '\pool2025_26', 'poolResults.xlsx');
hoja = 1;
carpetaSalida = 'resultados_graficas';

if ~exist(carpetaSalida, 'dir')
    mkdir(carpetaSalida);
end

% Número de evaluadores
nEval = 19;

% Nombre de las secciones en el Excel
secciones = { ...
    'Comprensión Conceptual', ...
    'Contenido Técnico', ...
    'Herramientas RTL+MATLAB', ...
    'Aprendizaje Aplicado', ...
    'Evaluación Global'};

%% LECTURA DEL EXCEL
% readcell permite trabajar con texto y números mezclados.
C = readcell(archivo, 'Sheet', hoja);

% Los datos de cada sección están delimitados por una fila de encabezado
% cuyo primer elemento coincide con el nombre de la sección.

datos = struct();

for s = 1:numel(secciones)

    % Buscar la fila de encabezado de la sección
    filaInicio = [];
    for r = 1:size(C,1)
        valor = C{r,1};
        if ischar(valor) || isstring(valor)
            if strcmp(strtrim(string(valor)), secciones{s})
                filaInicio = r;
                break;
            end
        end
    end

    if isempty(filaInicio)
        error('No se encontró la sección "%s".', secciones{s});
    end

    % La siguiente sección comienza en la siguiente fila que contiene
    % uno de los nombres de sección.
    filasSecciones = [];
    for ss = 1:numel(secciones)
        for r = 1:size(C,1)
            valor = C{r,1};
            if ischar(valor) || isstring(valor)
                if strcmp(strtrim(string(valor)), secciones{ss})
                    filasSecciones(end+1) = r; %#ok<SAGROW>
                end
            end
        end
    end

    filaFin = size(C,1);
    siguientes = filasSecciones(filasSecciones > filaInicio);
    if ~isempty(siguientes)
        filaFin = min(siguientes)-1;
    end

    % Filas válidas: todas excepto la fila "Resultados Sección".
    items = {};
    valores = [];

    for r = filaInicio+1:filaFin

        nombre = C{r,1};

        if isempty(nombre)
            continue;
        end

        nombre = strtrim(string(nombre));

        % Ignorar la fila de resultados agregados
        if contains(lower(nombre), 'resultdos sección') || ...
           contains(lower(nombre), 'resultados sección')
            continue;
        end

        % Leer los 19 evaluadores
        filaDatos = nan(1,nEval);

        for e = 1:nEval
            v = C{r,e+1};

            if isnumeric(v)
                filaDatos(e) = v;
            elseif ischar(v) || isstring(v)
                % Admite tanto 3.5 como 3,5
                txt = strrep(strtrim(string(v)), ',', '.');
                numero = str2double(txt);
                if ~isnan(numero)
                    filaDatos(e) = numero;
                end
            end
        end

        % Guardar solamente filas que tengan al menos un dato
        if any(~isnan(filaDatos))
            items{end+1} = char(nombre); %#ok<SAGROW>
            valores(end+1,:) = filaDatos; %#ok<SAGROW>
        end
    end

    datos(s).nombre = secciones{s};
    datos(s).items = items;
    datos(s).valores = valores;
end

%% RESUMEN NUMÉRICO
fprintf('\n=============================================\n');
fprintf('        RESUMEN DE LA ENCUESTA\n');
fprintf('=============================================\n\n');

mediaSeccion = nan(1,numel(secciones));
stdSeccion = nan(1,numel(secciones));

for s = 1:numel(secciones)
    v = datos(s).valores(:);
    mediaSeccion(s) = mean(v,'omitnan');
    stdSeccion(s) = std(v,'omitnan');

    fprintf('%-30s  Media = %.2f   SD = %.2f\n', ...
        datos(s).nombre, mediaSeccion(s), stdSeccion(s));
end

fprintf('\n');

%% 1. MEDIA POR ÍTEM
for s = 1:numel(secciones)

    V = datos(s).valores;
    medias = mean(V,2,'omitnan');
    desv = std(V,0,2,'omitnan');

    % Ordenar de mayor a menor
    [mediasOrd, idx] = sort(medias,'descend');
    nombresOrd = datos(s).items(idx);
    desvOrd = desv(idx);

    figure('Color','w','Position',[100 100 1100 650]);

    barh(mediasOrd);
    xlim([0 5]);
    xlabel('Valoración media (1-5)');
    ylabel('Ítem');

    title(['Valoración media - ' datos(s).nombre], ...
        'Interpreter','none','FontWeight','bold');

    set(gca,'YTick',1:numel(nombresOrd), ...
        'YTickLabel',nombresOrd, ...
        'FontSize',10);
    grid on;
    set(gca,'YDir','reverse');

    % Línea de referencia de aprobado / valoración media
    %xline(3,'--','Media = 3','LineWidth',1.2);
    fontsize(18,"points");
    % Añadir valor numérico al final de cada barra
    for k = 1:numel(mediasOrd)
        text(mediasOrd(k)+0.05,k,sprintf('%.2f',mediasOrd(k)), ...
            'VerticalAlignment','middle','FontSize',9);
    end

    exportgraphics(gcf, fullfile(carpetaSalida, ...
        sprintf('%02d_media_items.png',s)), 'Resolution',300);

    savefig(gcf, fullfile(carpetaSalida, ...
        sprintf('%02d_media_items.fig',s)));

    %close(gcf);
end

%% 2. COMPARACIÓN DE LAS SECCIONES
figure('Color','w','Position',[100 100 1000 600]);

b = bar(mediaSeccion);
ylim([0 5]);
ylabel('Valoración media (1-5)');
title('Valoración media por sección','FontWeight','bold');

set(gca,'XTick',1:numel(secciones), ...
    'XTickLabel',secciones, ...
    'FontSize',10);

grid on;
yline(3,'--','Media = 3','LineWidth',1.2);

for s = 1:numel(secciones)
    text(s,mediaSeccion(s)+0.12, ...
        sprintf('%.2f',mediaSeccion(s)), ...
        'HorizontalAlignment','center', ...
        'FontWeight','bold');
end

exportgraphics(gcf,fullfile(carpetaSalida, ...
    'comparacion_secciones.png'),'Resolution',300);

savefig(gcf,fullfile(carpetaSalida, ...
    'comparacion_secciones.fig'));

%close(gcf);

%% 3. DISTRIBUCIÓN LIKERT POR SECCIÓN
%
% Se calcula el porcentaje de respuestas 1, 2, 3, 4 y 5.

likert = zeros(numel(secciones),5);

for s = 1:numel(secciones)

    v = datos(s).valores(:);
    v = v(~isnan(v));

    for nivel = 1:5
        likert(s,nivel) = 100 * sum(v == nivel) / numel(v);
    end
end

figure('Color','w','Position',[100 100 1100 650]);

bar(likert,'stacked');

xlabel('Sección');
ylabel('Porcentaje de respuestas (%)');
title('Distribución de respuestas Likert por sección', ...
    'FontWeight','bold');

set(gca,'XTick',1:numel(secciones), ...
    'XTickLabel',secciones);

legend({'1','2','3','4','5'}, ...
    'Location','eastoutside');

ylim([0 100]);
grid on;

exportgraphics(gcf,fullfile(carpetaSalida, ...
    'distribucion_likert_secciones.png'),'Resolution',300);

savefig(gcf,fullfile(carpetaSalida, ...
    'distribucion_likert_secciones.fig'));

%close(gcf);

%% 4. DISTRIBUCIÓN LIKERT POR ÍTEM
%
% Una figura independiente para cada sección.

for s = 1:numel(secciones)

    V = datos(s).valores;
    nItems = size(V,1);

    likertItems = zeros(nItems,5);

    for i = 1:nItems
        v = V(i,:);
        v = v(~isnan(v));

        for nivel = 1:5
            likertItems(i,nivel) = ...
                100 * sum(v == nivel) / numel(v);
        end
    end

    figure('Color','w','Position',[100 100 1200 650]);

    barh(likertItems,'stacked');

    xlabel('Porcentaje de respuestas (%)');
    ylabel('Ítem');
    title(['Distribución Likert - ' datos(s).nombre], ...
        'Interpreter','none','FontWeight','bold');

    set(gca,'YTick',1:nItems, ...
        'YTickLabel',datos(s).items, ...
        'FontSize',9);
    set(gca,'YDir','reverse');

    xlim([0 100]);
    grid on;

    legend({'1','2','3','4','5'}, ...
        'Location','eastoutside');

    exportgraphics(gcf,fullfile(carpetaSalida, ...
        sprintf('%02d_likert_items.png',s)), ...
        'Resolution',300);

    savefig(gcf,fullfile(carpetaSalida, ...
        sprintf('%02d_likert_items.fig',s)));

    %close(gcf);
end

%% 5. COMPARACIÓN ENTRE EVALUADORES
%
% Cada evaluador obtiene la media de todas sus respuestas válidas.

mediaEvaluador = nan(nEval,numel(secciones));

for s = 1:numel(secciones)
    mediaEvaluador(:,s) = mean(datos(s).valores,1,'omitnan')';
end

mediaGlobalEvaluador = mean(mediaEvaluador,2,'omitnan');

figure('Color','w','Position',[100 100 1100 600]);

bar(1:nEval,mediaGlobalEvaluador);

ylim([0 5]);
xlabel('Evaluador');
ylabel('Valoración media');
title('Valoración media de cada evaluador','FontWeight','bold');

grid on;
yline(3,'--','Media = 3','LineWidth',1.2);

for e = 1:nEval
    text(e,mediaGlobalEvaluador(e)+0.10, ...
        sprintf('%.2f',mediaGlobalEvaluador(e)), ...
        'HorizontalAlignment','center', ...
        'FontSize',8);
end

exportgraphics(gcf,fullfile(carpetaSalida, ...
    'media_por_evaluador.png'),'Resolution',300);

savefig(gcf,fullfile(carpetaSalida, ...
    'media_por_evaluador.fig'));

%close(gcf);

%% 6. MATRIZ DE CALOR: EVALUADOR x SECCIÓN
figure('Color','w','Position',[100 100 1050 600]);

imagesc(mediaEvaluador');

cb = colorbar;
cb.Label.String = 'Valoración media';

caxis([1 5]);

xlabel('Evaluador');
ylabel('Sección');
title('Valoración por evaluador y sección','FontWeight','bold');

set(gca,'XTick',1:nEval, ...
    'YTick',1:numel(secciones), ...
    'YTickLabel',secciones);

% Escribir el valor en cada celda
for s = 1:numel(secciones)
    for e = 1:nEval
        text(e,s,sprintf('%.2f',mediaEvaluador(e,s)), ...
            'HorizontalAlignment','center', ...
            'FontSize',8);
    end
end

exportgraphics(gcf,fullfile(carpetaSalida, ...
    'mapa_calor_evaluadores_secciones.png'),'Resolution',300);

savefig(gcf,fullfile(carpetaSalida, ...
    'mapa_calor_evaluadores_secciones.fig'));

%close(gcf);

%% 7. RADAR DE LAS SECCIONES
%
% Requiere MATLAB moderno con polaraxes.

angulos = linspace(0,2*pi,numel(secciones)+1);
valoresRadar = [mediaSeccion mediaSeccion(1)];

figure('Color','w','Position',[100 100 700 700]);

pax = polaraxes;
hold(pax,'on');

polarplot(pax,angulos,valoresRadar, ...
    'LineWidth',2);

rlim([0 5]);
rticks(0:1:5);

thetaticks(rad2deg(angulos(1:end-1)));
thetaticklabels(secciones);

title('Perfil global de la evaluación','FontWeight','bold');

exportgraphics(gcf,fullfile(carpetaSalida, ...
    'radar_secciones.png'),'Resolution',300);

savefig(gcf,fullfile(carpetaSalida, ...
    'radar_secciones.fig'));

%close(gcf);

%% 8. TABLAS DE RESULTADOS
%
% Crear tabla resumen de las secciones.

TablaSecciones = table( ...
    string(secciones(:)), ...
    mediaSeccion(:), ...
    stdSeccion(:), ...
    'VariableNames',{'Seccion','Media','DesviacionEstandar'});

writetable(TablaSecciones, ...
    fullfile(carpetaSalida,'resumen_secciones.xlsx'));

% Crear tabla con media por ítem.
for s = 1:numel(secciones)

    V = datos(s).valores;

    TablaItems = table( ...
        string(datos(s).items(:)), ...
        mean(V,2,'omitnan'), ...
        std(V,0,2,'omitnan'), ...
        'VariableNames',{'Item','Media','DesviacionEstandar'});

    nombreArchivo = sprintf('%02d_items_%s.xlsx', ...
        s, limpiarNombreArchivo(secciones{s}));

    writetable(TablaItems, ...
        fullfile(carpetaSalida,nombreArchivo));
end

% Tabla evaluador x sección
nombresEval = "Eval " + string((1:nEval)');

TablaEvaluadores = array2table(mediaEvaluador, ...
    'VariableNames',matlab.lang.makeValidName(secciones), ...
    'RowNames',cellstr(nombresEval));

writetable(TablaEvaluadores, ...
    fullfile(carpetaSalida,'evaluadores_por_seccion.xlsx'), ...
    'WriteRowNames',true);

%% FINAL
fprintf('=============================================\n');
fprintf('ANÁLISIS TERMINADO\n');
fprintf('=============================================\n');
fprintf('Las gráficas y tablas se han guardado en:\n');
fprintf('  %s\n\n', fullfile(pwd,carpetaSalida));

%% FUNCIÓN AUXILIAR
function nombre = limpiarNombreArchivo(txt)

    nombre = regexprep(txt,'[^\w\s-]','');
    nombre = strrep(nombre,' ','_');
    nombre = regexprep(nombre,'_+','_');

end
