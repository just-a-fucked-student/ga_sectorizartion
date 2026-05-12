function [objV, obj1, obj2, obj3, obj4] = objFun(phenotypes)
%objFun Evaluates the sectoring workload for aircraft management.
%
% Syntax:
%   [objV, obj1, obj2, obj3, obj4] = objFun(phenotypes)
%
% Description:
%   This function computes multiple workload-related objective values 
%   for a given set of phenotypes, which define Voronoi sectors in an 
%   airspace management scenario.
%   It assesses the complexity of each sector configuration and calculates 
%   specific workload metrics.
%
% Inputs:
%   phenotypes - A matrix where each row represents a set of coordinates
%                alternating between longitudes and latitudes, 
%                defining the Voronoi points for sectorization.
%
% Outputs:
%   objV  - Vector of aggregated objective values for each phenotype.
%   obj1, obj2, obj3, obj4 - Vectors of objective metrics for each 
%                            phenotype, typically related to workload 
%                            balance among sectors.
%
% Notes:
%   The function loads an airspace data set containing all the required 
%   airspace-related data.
%
% See also:
%   complexityFunction, voronoi, std, mean

% Load airspace dataset
airspace = load(fullfile('data','airspace.mat'));

% Number of phenotypes in the input list
nPhenos = size(phenotypes,1);

% Preallocate cost variables
objV = zeros(nPhenos, 1);
obj1 = zeros(nPhenos, 1);
obj2 = zeros(nPhenos, 1);
obj3 = zeros(nPhenos, 1);
obj4 = zeros(nPhenos, 1);

% Compute costs on each dimension of the phenotype
for i=1:nPhenos

    % Recover the voronoid structure from the current phenotype
    vorxy = phenotype2vor(phenotypes(i,:));
    
    % Add boundary voronoi (this avoids infinite sectors near FIR)
    vor = [vorxy; airspace.vorBounds]; 

    % Compute the complexity of each sector     
    comp = complexityFunction(vor, airspace);
    
    % Normalize complexity data 
    % ...
    
    % Define single objective functions: 
    %   Standard deviations of each type of workload
    %
    % Logic:
    % Ex: minimize variance of aircraft/sec == all sectors same aircrafts
    % Ex: minimize sum() of intersect == less interections overall
    %
    % Workload related to Background tasks 
    obj1(i,1) = ;
    % Workload related to Transition tasks
    obj2(i,1) = ;
    % Workload related to Recurring tasks
    obj3(i,1) = ;
    % Workload related to Conflict tasks
    obj4(i,1) = ;
    
    % Check if your objective functions are well normalized
    % ...
    
    % Define global objective function
    
    objV(i,1) = ; 

end

end
