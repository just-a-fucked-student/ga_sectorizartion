function [V, C] = generateVoronoiNoInf(x)
%GENERATEVORONOINOINF Generates a Voronoi diagram excluding cells with 
%   infinite vertices.
%
% Syntax:
%   [V, C] = generateVoronoiNoInf(x)
%
% Description:
%   This function calculates the Voronoi diagram for a given set of points 
%   in 2D space and returns the vertices and cell indices excluding any 
%   cells that extend to infinity.
%   This is particularly useful in bounded Voronoi diagram applications 
%   where infinite cells can complicate the computation and analysis.
%
% Inputs:
%   x - An Nx2 array of points for which the Voronoi diagram is to be 
%       generated. Each row represents a point with x and y coordinates.
%
% Outputs:
%   V - An Mx2 array of vertices of the Voronoi diagram, where M is the 
%       number of vertices.
%       Each row represents a vertex with its x and y coordinates.
%   C - A cell array where each cell contains the indices of the vertices 
%       that make up a Voronoi cell. 
%       Cells that would normally extend to infinity are excluded.
%
% See also:
%   voronoin, cellfun

% Generate Voronoi diagram
[V, C] = voronoin(x);

% Filter out cells containing points at infinity (index 1)
C = C(cellfun(@(c) all(c~=1), C));

end

