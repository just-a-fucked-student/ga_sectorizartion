function [MobjV, obj1, obj2, obj3, obj4] = MultiobjFun(phenotypes)
%objFun Evaluates the sectoring workload for aircraft management.
%
% Syntax:
%   [objV, obj1, obj2, obj3, obj4] = MultiobjFun(phenotypes)
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
%   objV  - Vector of multi objective values for each phenotype.
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

