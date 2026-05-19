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



%% SECTION 10: MULTI-OBJECTIVE OPTIMIZATION (WP3)
fprintf('\n--- MULTI-OBJECTIVE GA (WP3) ---\n');

% 1. Definim la funció anònima passant l'airspace
FitnessFunction = @(x) MultiobjFun(x, airspace);

% 2. Opcions de l'algorisme (Posem @gaplotparetodistance per tenir les BARRES)
options = optimoptions('gamultiobj', ...
    'PopulationSize', 60, ...
    'MaxGenerations', 60, ...
    'CrossoverFraction', 0.8, ...
    'ParetoFraction', 0.3, ...
    'UseVectorized', true, ...    
    'Display', 'iter', ...
    'PlotFcn', {@gaplotpareto, @gaplotgenealogy, @gaplotrankhist, @gaplotparetodistance});

fprintf('Executant gamultiobj (FINESTRA 1: Gràfiques d''evolució)...\n');
[x_pareto, fval_pareto, exitflag, output] = gamultiobj(FitnessFunction, NVAR, ...
    [], [], [], [], LB, UB, [], options);

fprintf('Optimització Multi-Objectiu Completada.\n');

%% 3. SELECCIÓ I DIBUIX DE LA SECTORITZACIÓ (FINESTRA 2)
% Calcular la solució més equilibrada (més propera al 0,0)
distances = sqrt(fval_pareto(:,1).^2 + fval_pareto(:,2).^2);
[~, best_idx] = min(distances);

best_multi_phenotype = x_pareto(best_idx, :);
best_multi_fval = fval_pareto(best_idx, :);

% Mostrar per consola el resultat guanyador
fprintf('\nSolució equilibrada seleccionada (índex %d):\n', best_idx);
fprintf('  Interseccions de rutes (RSD): %.4f\n', best_multi_fval(1));
fprintf('  Balanç d''avions (RSD): %.4f\n', best_multi_fval(2));

ah_multi = plotAirspace(airspace); % Això ja obre la finestra sola
hold(ah_multi, 'on');

% Obtenir les coordenades i dibuixar els sectors Voronoi
vorxy_multi = phenotype2vor(best_multi_phenotype);
plotVoronoiSectors(ah_multi, vorxy_multi(:,1), vorxy_multi(:,2), airspace);

title('Airspace Sectoring', 'FontSize', 14);

fprintf('\nTODO HECHO!\n');

%% ALL DONE

% Info
fprintf('TODO HECHO!\n');
fprintf('------------------------------------------------------------\n');
