%% SECTION 1: CLEAR WORKSPACE
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

% Add functions subdir to the path
addpath functions/
addpath objectives_student/

%% SECTION 2: LOAD AIRSPACE DATA

% Define datafile paths
fNavWpts = 'data/NavWpts.dat'; % Airspace waypoints
fAirways = 'data/Airways.dat'; % Definition of airways
fFir = 'data/FIR.dat'; % Definition of FIR
fAC = 'data/LatLon-FIR-FL300up-filt-1155-1210.dat'; % Traffic data

% Load all airspace datafiles
airspace = loadAirspace(fNavWpts, fFir, fAirways, fAC);

% Save airspace object
% To load it: airspace = load('data/airspace.mat');
save('data/airspace.mat', '-struct', 'airspace');

% Plot Airspace
% We save the plot axis "ah" so we can keep plotting stuff there
ah = plotAirspace(airspace);

%% SECTION 3: GENETIC ALGORITHM CONFIGURATION

% Number of sectors 
NSECT = 5; 

% Number of variables (coords {x,y} per sector)
NVAR = 2 * NSECT; 

% Boundaries of the Search Space
axisBounds = airspace.axisBounds; % [minLon, maxLon, minLat, maxLat]
LB = repmat([axisBounds(1), axisBounds(3)], 1, NSECT); % Lower bounds for all points
UB = repmat([axisBounds(2), axisBounds(4)], 1, NSECT); % Upper bounds for all points

% Maximum number of generations
MaxGen = 15;

% Population Size
PS = 30;

% Elite Count
% Individuals in the current generation with the best fitness values
% These individuals automatically survive to the next generation
% This parameter applies only to Single-objective GA
EC = 2; 

% Crossover Fraction
% Individuals created by combining the vectors of a pair of parents
CF = 0.4; % Percentage of the population [0-1]

% Mutation Fraction
% Individuals created by perturbing an individual by an offset
% This parameter applies only to AGA
MF = 0.3; % Percentage of the population [0-1]

% Newcomers Fraction
% Random new individuals introduced to the population
% This parameter applies only to AGA
NF = 0.1; % Percentage of the population [0-1]

% Pareto Fraction
% This parameter applies only to Multi-objective GA
PF = 0.5; % [0-1]

%% SECTION 4: GENETIC ALGORITHM OPTIMISATION (AGA)
% SINGLE OBJECTIVE

% Info
fprintf('SINGLE-OBJECTIVE GA 1D (AGA) -------------------------------\n');

% Define objective function
objFun1D = @(x) objFun(x);

% GA options
goal = 0.0; % Target value
ng = MaxGen; % Maximum generations
np = PS; % Population size
ne = EC; % Number of elites
nm = round(np * MF); % Number of mutants
nn = round(np * NF); % Number of newcomers
na = round(np * CF); % Number of parents
n = NSECT; % Phenotype size (number of voronoi sectors)

% Solve with AGA
res = aga(goal, ng, np, ne, nm, nn, na, objFun1D, LB, UB);

% Solution
phenotype = res.bestind; % Best phenotype
fval = res.bestfit; % Best fitness

% Safety-check
if isempty(phenotype), return; end

%% SECTION 5: OPTIMISATION RESULTS OF AGA

% Recover the voronoid structure from the phenotype
vorxy = phenotype2vor(phenotype);

% Add boundary voronoi (this avoids infinite sectors near FIR)
vorxyB = [vorxy; airspace.vorBounds]; 

% Obtain the complexity of the final (optimal) sectorization
comp = complexityFunction(vorxyB, airspace);

% Plot the voronoi sectors into the main Airspace plot "ah"
plotVoronoiSectors(ah, vorxy(:,1), vorxy(:,2), airspace);

% Display results
fprintf("Best cost: %.2f\n", fval);
disp('Best individual:');
disp(vorxy);
disp('Complexity:');
disp(struct2table(comp));

%% SECTION 6: FUTURE WORK PACKAGE 2
% Placeholder para comparación GA MATLAB y análisis adicionales.

%% SECTION 7: FUTURE WORK PACKAGE 3
% Placeholder para comparación GA MATLAB y análisis adicionales.

%% SECTION 8: FUTURE WORK PACKAGE 4
% Placeholder para Monte-Carlo y multiobjetivo.

%% ALL DONE

% Info
fprintf('ALL DONE!\n');
fprintf('------------------------------------------------------------\n');

