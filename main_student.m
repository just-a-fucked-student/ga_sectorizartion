%% SECTION 1: CLEAR WORKSPACE
% Limpiar todo y mostrar logo
close all
clear
clc

% Info
disp(" _   _ ___________ _____ _   _ _____ _____ ");
disp("| | | |  _  | ___ |  _  | \ | |  _  |_   _|");
disp("| | | | | | | |_/ | | | |  \| | | | | | |  ");
disp("| | | | | | |    /| | | | . ` | | | | | |  ");
disp("\ \_/ \ \_/ | |\ \\ \_/ | |\  \ \_/ /_| |_ ");
disp(" \___/ \___/\_| \_|\___/\_| \_/\___/ \___/ ");
disp('>> AIRSPACE SECTORISATION WITH VORONOI <<');
disp('=============================================');

% Agregar carpetas de funciones al path
addpath functions/
addpath objectives_student/

%% SECTION 2: LOAD AIRSPACE DATA
% Cargar datos del espacio aéreo

% Definir rutas de archivos de datos
fNavWpts = 'data/NavWpts.dat'; % Waypoints del espacio aéreo
fAirways = 'data/Airways.dat'; % Definición de airways
fFir = 'data/FIR.dat'; % Definición de FIR
fAC = 'data/LatLon-FIR-FL300up-filt-0755-0810.dat'; % Datos de tráfico

% Cargar todos los archivos de datos
airspace = loadAirspace(fNavWpts, fFir, fAirways, fAC);

% Guardar objeto airspace
% Para cargar: airspace = load('data/airspace.mat');
save('data/airspace.mat', '-struct', 'airspace');

% Dibujar el espacio aéreo
% Guardamos el eje del plot "ah" para seguir dibujando
ah = plotAirspace(airspace);

%% SECTION 3: GENETIC ALGORITHM CONFIGURATION
% Configurar parámetros del algoritmo genético

% Número de sectores
NSECT = 5; 

% Número de variables (coords {x,y} por sector)
NVAR = 2 * NSECT; 

% Límites del espacio de búsqueda
axisBounds = airspace.axisBounds; % [minLon, maxLon, minLat, maxLat]
LB = repmat([axisBounds(1), axisBounds(3)], 1, NSECT); % Límites inferiores
UB = repmat([axisBounds(2), axisBounds(4)], 1, NSECT); % Límites superiores

% Máximo número de generaciones
MaxGen = 15;

% Tamaño de población
PS = 30;

% Número de elites
% Individuos con mejor fitness pasan automáticamente a la siguiente generación
% Solo para GA mono-objetivo
EC = 2; 

% Fracción de cruce
% Individuos creados combinando padres
CF = 0.4; % Porcentaje de la población [0-1]

% Fracción de mutación
% Individuos creados perturbando uno existente
% Solo para AGA
MF = 0.3; % Porcentaje de la población [0-1]

% Fracción de nuevos
% Individuos nuevos aleatorios
% Solo para AGA
NF = 0.1; % Porcentaje de la población [0-1]

% Fracción de Pareto
% Para GA multi-objetivo
PF = 0.5; % [0-1]

%% SECTION 4: GENETIC ALGORITHM OPTIMISATION (AGA)
% OPTIMIZACIÓN CON GA MONO-OBJETIVO

% Mensaje de info
fprintf('SINGLE-OBJECTIVE GA 1D (AGA) -------------------------------\n');

% Definir función objetivo
objFun1D = @(x) objFun(x);

% Opciones del GA
goal = 0.0; % Valor objetivo
ng = MaxGen; % Máximo generaciones
np = PS; % Tamaño población
ne = EC; % Número de elites
nm = round(np * MF); % Número de mutantes
nn = round(np * NF); % Número de nuevos
na = round(np * CF); % Número de padres
n = NSECT; % Tamaño del fenotipo (número de sectores Voronoi)

% Resolver con AGA
res = aga(goal, ng, np, ne, nm, nn, na, objFun1D, LB, UB);

% Solución
phenotype = res.bestind; % Mejor fenotipo
fval = res.bestfit; % Mejor fitness

% Verificación de seguridad
if isempty(phenotype), return; end

%% SECTION 5: OPTIMISATION RESULTS OF AGA
% RESULTADOS DE LA OPTIMIZACIÓN CON AGA

% Recuperar estructura Voronoi del fenotipo
vorxy = phenotype2vor(phenotype);

% Agregar límites Voronoi para evitar sectores infinitos cerca de FIR
vorxyB = [vorxy; airspace.vorBounds]; 

% Calcular complejidad de la sectorización final
comp = complexityFunction(vorxyB, airspace);

% Dibujar sectores Voronoi en el plot principal "ah"
plotVoronoiSectors(ah, vorxy(:,1), vorxy(:,2), airspace);

% Mostrar resultados
fprintf("Mejor costo: %.2f\n", fval);
disp('Mejor individuo:');
disp(vorxy);
disp('Complejidad:');
disp(struct2table(comp));

%% SECTION 8: HYPER-PARAMETER TUNING (WP2)
fprintf('Iniciant Hyper-Parameter Tuning...\n');

% Llistes de paràmetres a provar (modifica-ho segons el que vulguis esperar)
PS_list = [10, 20, 30];       % Provarem 3 mides de població
MaxGen_list = [10, 20, 30];   % Provarem 3 màxims de generacions
MC_hpt = 150;                 % El teu N ideal estabilitzat

% Matriu per guardar les mitjanes dels resultats finals
mean_fitness_matrix = zeros(length(MaxGen_list), length(PS_list));

% Calcular el total d'execucions per tenir una idea del temps
total_runs = length(PS_list) * length(MaxGen_list) * MC_hpt;
fprintf('Atenció: Es faran un total de %d execucions de l''AGA.\n', total_runs);
run_counter = 0;

for i = 1:length(MaxGen_list)
    ng = MaxGen_list(i);

    for j = 1:length(PS_list)
        np = PS_list(j);

        % Recalcular paràmetres derivats per a l'AGA segons aquesta Població (np)
        ne = 2; % Elits
        nm = round(np * 0.3); % Mutants (30% per defecte, comprova els teus apunts)
        nn = round(np * 0.1); % Nous (10%)
        na = round(np * 0.4); % Pares (40%)

        fprintf('\nTestejant PS = %d | MaxGen = %d...\n', np, ng);

        costos_actuals = zeros(MC_hpt, 1);

        % Bucle Monte Carlo per a aquesta combinació
        for k = 1:MC_hpt
            % Executar AGA
            res = aga(0.0, ng, np, ne, nm, nn, na, objFun1D, LB, UB);
            costos_actuals(k) = res.bestfit;

            run_counter = run_counter + 1;
            if mod(run_counter, 100) == 0
                fprintf('  ... %d/%d execucions completades\n', run_counter, total_runs);
            end
        end

        % Guardar la mitjana d'aquesta casella a la matriu
        mean_fitness_matrix(i, j) = mean(costos_actuals);
    end
end

% Guardar els resultats en un arxiu .mat
save('data/hpt_results.mat', 'mean_fitness_matrix', 'PS_list', 'MaxGen_list');
fprintf('Hyper-Parameter Tuning finalitzat!\n');

%% SECTION 9: POST-PROCESSING HPT (Heatmap)
figure('Name', 'HPT - Mean Fitness');

% Dibuixar el Heatmap
imagesc(PS_list, MaxGen_list, mean_fitness_matrix);
colorbar;
colormap('parula'); % Escala de colors similar a la de les slides
xlabel('Population');
ylabel('Generations');
title('Mean Fitness Value');

% Posar els eixos en ordre ascendent (de baix cap a dalt)
set(gca, 'YDir', 'normal'); 

% Mostrar la configuració òptima guanyadora per consola
[min_val, min_idx] = min(mean_fitness_matrix(:));
[row_min, col_min] = ind2sub(size(mean_fitness_matrix), min_idx);
fprintf('\n>> LA MILLOR CONFIGURACIÓ ÉS:\n');
fprintf('Population (PS) = %d\n', PS_list(col_min));
fprintf('Max Generations = %d\n', MaxGen_list(row_min));
fprintf('Amb un cost mitjà de: %.4f\n', min_val);

%% SECTION 7: FUTURE WORK PACKAGE 3
% Placeholder para comparación GA MATLAB y análisis adicionales.

%% SECTION 8: FUTURE WORK PACKAGE 4
% Placeholder para Monte-Carlo y multiobjetivo.

%% ALL DONE

% Info
fprintf('TODO HECHO!\n');
fprintf('------------------------------------------------------------\n');
