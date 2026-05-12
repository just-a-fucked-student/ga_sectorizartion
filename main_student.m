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
NSECT = ; 

% Number of variables (coords {x,y} per sector)
NVAR = ; 

% Boundaries of the Search Space
LB = ; % Lower bounds
UB = ; % Upper bounds

% Maximum number of generations
MaxGen = ;

% Population Size
PS = ;

% Elite Count
% Individuals in the current generation with the best fitness values
% These individuals automatically survive to the next generation
% This parameter applies only to Single-objective GA
EC = ; 

% Crossover Fraction
% Individuals created by combining the vectors of a pair of parents
CF = ; % Percentage of the population [0-1]

% Mutation Fraction
% Individuals created by perturbing an individual by an offset
% This parameter applies only to AGA
MF = ; % Percentage of the population [0-1]

% Newcomers Fraction
% Random new individuals introduced to the population
% This parameter applies only to AGA
NF = ; % Percentage of the population [0-1]

% Pareto Fraction
% This parameter applies only to Multi-objective GA
PF = ; % [0-1]

%% SECTION 4: GENETIC ALGORITHM OPTIMISATION (AGA)
% SINGLE OBJECTIVE

% Info
fprintf('SINGLE-OBJECTIVE GA 1D (AGA) -------------------------------\n');

% Define objective function
objFun1D = ;

% GA options
goal = 0.0; % Target value
ng = MaxGen; % Maximum generations
np = PS; % Population size
ne = EC; % Number of elites
nm = np * MF; % Number of mutants
nn = np * NF; % Number of newcomers
na = np * CF; % Number of parents
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

%% SECTION 6: GENETIC ALGORITHM OPTIMISATION (MATLAB)
% SINGLE OBJECTIVE

% Info
fprintf('SINGLE-OBJECTIVE GA 1D (MATLAB) ----------------------------\n');

% Define objective function
objFun1D = ;

% GA options
options1D = optimoptions('ga', ...
    'MaxGenerations', MaxGen, ...
    'PopulationSize', PS, ...
    'CrossoverFraction', CF, ...
    'EliteCount', EC, ...
    'PlotFcn', {@gaplotbestf, @gaplotgenealogy});

% Solve with GA
[ phenotype, fval, ~, ~, ~, ~ ] = ga ( ...
    objFun1D, NVAR, [], [], [], [], LB, UB, [], options1D );

%% SECTION 7: OPTIMISATION RESULTS

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

%% SECTION 8: MONTE-CARLO ANALYSIS

%% SECTION 9: MONTE-CARLO STATISTICS

%% SECTION 10a: MULTI-OBJECTIVE OPTIMIZATION 2D (weighted sums)

%% SECTION 10b: MULTI-OBJECTIVE OPTIMIZATION 2D (MOO)

% Info
fprintf('MULTI-OBJECTIVE GA 2D --------------------------------------\n');

% Objective function
objFun2D = ;

% Options for multi-objective GA
options2D = optimoptions('gamultiobj',...
    'PopulationSize', PS, ...
    'CrossoverFraction', CF, ...
    'MaxGenerations', MaxGen, ...
    'ParetoFraction', PF, ...
    'PlotFcn', { ...
    @gaplotpareto, ...
    @gaplotgenealogy, ...
    @gaplotrankhist, ...
    @gaplotparetodistance});

% Optimise
[paretoPheno2D, fval2D, exitflag2D, output2D, population2D, scores2D] = ...
    gamultiobj(objFun2D, NVAR, [], [], [], [], LB, UB, [], options2D);

%% SECTION 11: 2D MOO RESULTS

% Recover the voronoid structure from the phenotype
% We will take the first individual from the pareto!
vorxy = phenotype2vor(paretoPheno2D(1,:));

% Add boundary voronoi (this avoids infinite sectors near FIR)
vorxyB = [vorxy; airspace.vorBounds];

% Obtain the complexity of the final (optimal) sectorization
comp = complexityFunction(vorxyB, airspace);

% Plot the voronoi sectors into the main Airspace plot "ah"
plotVoronoiSectors(ah, vorxy(:,1), vorxy(:,2), airspace);

% Display results
disp('First individual in the pareto 2D:');
disp(vorxy);
fprintf("Cost of this individual: %.2f %.2f\n", fval2D(1,:));
disp('Complexity:');
disp(struct2table(comp));

%% ALL DONE

% Info
fprintf('ALL DONE!\n');
fprintf('------------------------------------------------------------\n');
