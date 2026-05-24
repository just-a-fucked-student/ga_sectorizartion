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
MaxGen = 30;

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

% Resolver con AGA (con cronometraje para comparar con el toolbox)
tic;
res = aga(goal, ng, np, ne, nm, nn, na, objFun1D, LB, UB);
tAGA = toc;
fprintf('AGA finalizado en %.2f s | best cost = %.4f\n', tAGA, res.bestfit);

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

%% SECTION 6: GA TOOLBOX OPTIMISATION (Matlab built-in ga)
% Mismo problema, mismo coste (RSD de airway intersections), 
% pero ahora con el GA del Global Optimization Toolbox para comparar.
fprintf('\nSINGLE-OBJECTIVE GA (Matlab toolbox) ---------------------\n');

% Reutilizamos objFun: ga solo lee la primera salida (objV) 
ga_objFun = @(x) objFun(x);

% Opciones equivalentes a las del AGA para que la comparación sea justa:
% misma PS, misma MaxGen, mismo CrossoverFraction, mismo EliteCount.
% (El GA toolbox no tiene MF ni NC explícitos: los mutantes salen 
%  automáticamente del resto de la población tras elites y crossover.)
ga_opts = optimoptions('ga', ...
    'PopulationSize',    PS, ...
    'MaxGenerations',    MaxGen, ...
    'CrossoverFraction', CF, ...
    'EliteCount',        EC, ...
    'Display',           'iter', ...
    'UseVectorized',     true, ...
    'PlotFcn',           {@gaplotbestf});

% Lanzar el GA del toolbox con cronómetro
tic;
[x_ga, fval_ga, exitflag_ga, output_ga] = ga(ga_objFun, NVAR, ...
    [], [], [], [], LB, UB, [], ga_opts);
tGA = toc;

fprintf('GA toolbox finalizado en %.2f s | best cost = %.4f\n', tGA, fval_ga);

%% SECTION 7: OPTIMISATION RESULTS OF GA TOOLBOX
% Reconstruir la sectorización a partir del mejor fenotipo del toolbox
vorxy_ga  = phenotype2vor(x_ga);
vorxyB_ga = [vorxy_ga; airspace.vorBounds];
comp_ga   = complexityFunction(vorxyB_ga, airspace);

% Plot en figura nueva para no machacar el del AGA
ah_ga = plotAirspace(airspace);
plotVoronoiSectors(ah_ga, vorxy_ga(:,1), vorxy_ga(:,2), airspace);
title(ah_ga, sprintf('GA toolbox  -  cost = %.3f', fval_ga));

fprintf('Mejor individuo (GA toolbox):\n');
disp(vorxy_ga);
fprintf('Complejidad por sector (GA toolbox):\n');
disp(struct2table(comp_ga));

%% ===== AGA vs GA TOOLBOX: TABLA COMPARATIVA =====
fprintf('\n========== COMPARATIVA AGA vs GA TOOLBOX ==========\n');
fprintf('%-25s | %-12s | %-12s\n', 'Métrica', 'AGA', 'GA toolbox');
fprintf('%s\n', repmat('-', 1, 55));
fprintf('%-25s | %-12.4f | %-12.4f\n', 'Best cost (RSD AwyInt)', res.bestfit, fval_ga);
fprintf('%-25s | %-12.2f | %-12.2f\n', 'Tiempo [s]',             tAGA,        tGA);
fprintf('%-25s | %-12s | %-12s\n',     'Aircraft per sector', ...
    mat2str(comp.aircraftInSector(:)'),   mat2str(comp_ga.aircraftInSector(:)'));
fprintf('%-25s | %-12s | %-12s\n',     'AwyInt per sector', ...
    mat2str(comp.airwaysIntersections(:)'), mat2str(comp_ga.airwaysIntersections(:)'));
fprintf('%-25s | %-12s | %-12s\n',     'FIR transfers per sect', ...
    mat2str(comp.firTransfers(:)'),       mat2str(comp_ga.firTransfers(:)'));
fprintf('===================================================\n\n');


return; % STOP AQUÍ PARA HACER LA COMPARATIVA AGA vs GA TOOLBOX ANTES DE SEGUIR CON EL WP3

%% SECTION 10: MULTI-OBJECTIVE OPTIMIZATION (WP3)
fprintf('\n--- MULTI-OBJECTIVE GA (WP3) ---\n');

% 1. Definim la funció anònima passant l'airspace
FitnessFunction = @(x) MultiobjFun(x, airspace);

% 2. Opcions de l'algorisme (Posem @gaplotparetodistance per tenir les BARRES)
options = optimoptions('gamultiobj', ...
    'PopulationSize', 50, ...
    'MaxGenerations', 50, ...
    'CrossoverFraction', 0.8, ...
    'ParetoFraction', 0.3, ...
    'UseVectorized', true, ...    
    'Display', 'iter', ...
    'PlotFcn', {@gaplotpareto, @gaplotgenealogy, @gaplotrankhist, @gaplotparetodistance});

fprintf('Executant gamultiobj (FINESTRA 1: Gràfiques d''evolució)...\n');
[x_pareto, fval_pareto, exitflag, output] = gamultiobj(FitnessFunction, NVAR, ...
    [], [], [], [], LB, UB, [], options);

fprintf('Optimització Multi-Objectiu Completada.\n');

%% 3. SELECCIÓ I DIBUIX DE LES 3 SOLUCIONS DEL PARETO (WP3 Final)

% 1. Ordenem el Front de Pareto basant-nos en l'Objectiu 1 (eix X)
[~, sort_idx] = sort(fval_pareto(:,1));

% Extraiem els índexs de les tres solucions clau
idx_C = sort_idx(1);       % Extrem Esquerre: Millor per Obj 1, Pitjor per Obj 2
idx_A = sort_idx(end);     % Extrem Dret: Pitjor per Obj 1, Millor per Obj 2

% Solució B (Centre equilibrat)
distances = sqrt(fval_pareto(:,1).^2 + fval_pareto(:,2).^2);
[~, idx_B] = min(distances);

fprintf('\n--- GENERANT LES 3 SOLUCIONS DEL PARETO ---\n');

% --- SOLUCIÓ A (Extrem Dret - Focus en Interseccions) ---
ahA = plotAirspace(airspace); 
hold(ahA, 'on');
vorxyA = phenotype2vor(x_pareto(idx_A, :));
plotVoronoiSectors(ahA, vorxyA(:,1), vorxyA(:,2), airspace);
title(ahA, 'Solution A (Right Extremity - Area/Intersections Focused)', 'FontSize', 12);
set(ahA.Parent, 'Name', 'Solution A'); % Li posem nom a la finestra directament

% --- SOLUCIÓ B (Centre - Equilibrat) ---
ahB = plotAirspace(airspace); 
hold(ahB, 'on');
vorxyB = phenotype2vor(x_pareto(idx_B, :));
plotVoronoiSectors(ahB, vorxyB(:,1), vorxyB(:,2), airspace);
title(ahB, 'Solution B (Knee Point - Balanced)', 'FontSize', 12);
set(ahB.Parent, 'Name', 'Solution B');

% --- SOLUCIÓ C (Extrem Esquerre - Focus en Trànsit) ---
ahC = plotAirspace(airspace); 
hold(ahC, 'on');
vorxyC = phenotype2vor(x_pareto(idx_C, :));
plotVoronoiSectors(ahC, vorxyC(:,1), vorxyC(:,2), airspace);
title(ahC, 'Solution C (Left Extremity - Traffic Focused)', 'FontSize', 12);
set(ahC.Parent, 'Name', 'Solution C');

fprintf('Les tres figures s''han generat correctament!\n');

%% ALL DONE

% Info
fprintf('TODO HECHO!\n');
fprintf('------------------------------------------------------------\n');
