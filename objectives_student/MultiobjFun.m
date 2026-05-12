function [MobjV, obj1, obj2, obj3, obj4] = MultiobjFun(phenotypes)
%MultiobjFun Evaluates multiple objectives for sectorization.
%
% Syntax:
%   [MobjV, obj1, obj2, obj3, obj4] = MultiobjFun(phenotypes)
%
% Description:
%   This function computes a bi-objective cost for a set of phenotypes.
%   It returns both the airway intersections cost and a workload balance
%   metric to be used by a multi-objective GA.
%
% Inputs:
%   phenotypes - A matrix where each row represents a set of coordinates
%                alternating between longitudes and latitudes.
%
% Outputs:
%   MobjV - Matrix of objective values [nPhenotypes x 2].
%   obj1   - Aircraft distribution balance metric.
%   obj2   - FIR transfer balance metric.
%   obj3   - Sector transfer balance metric.
%   obj4   - Total airway intersections cost.

% Load airspace dataset
airspace = load(fullfile('data','airspace.mat'));

% Number of phenotypes in the input list
nPhenos = size(phenotypes,1);

% Preallocate cost variables
MobjV = zeros(nPhenos, 2);
obj1 = zeros(nPhenos, 1);
obj2 = zeros(nPhenos, 1);
obj3 = zeros(nPhenos, 1);
obj4 = zeros(nPhenos, 1);

for i = 1:nPhenos
    % Recover the voronoid structure from the current phenotype
    vorxy = phenotype2vor(phenotypes(i,:));
    % Add boundary voronoi (this avoids infinite sectors near FIR)
    vor = [vorxy; airspace.vorBounds];

    % Compute the complexity of each sector
    comp = complexityFunction(vor, airspace);

    % Objectives for multi-objective optimization
    obj1(i,1) = std(comp.aircraftInSector);
    obj2(i,1) = std(comp.firTransfers);
    obj3(i,1) = std(comp.sectorTransfers);
    obj4(i,1) = sum(comp.airwaysIntersections);

    % Multi-objective vector:
    %   1) minimize airway intersections
    %   2) minimize aircraft distribution imbalance
    MobjV(i,:) = [obj4(i,1), obj1(i,1)];
end

end

