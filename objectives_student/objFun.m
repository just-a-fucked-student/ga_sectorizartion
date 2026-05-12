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
    
    % Workload related to Background tasks: aircraft balance across sectors
    obj1(i,1) = std(comp.aircraftInSector);
    % Workload related to Transition tasks: FIR transfer balance
    obj2(i,1) = std(comp.firTransfers);
    % Workload related to Recurring tasks: airway-sector transfer balance
    obj3(i,1) = std(comp.sectorTransfers);
    % Workload related to Conflict tasks: total airway intersections
    obj4(i,1) = sum(comp.airwaysIntersections);
    
    % Global objective: minimize airway intersections as main cost
    objV(i,1) = obj4(i,1);

end

end
