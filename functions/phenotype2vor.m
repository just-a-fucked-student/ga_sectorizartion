function vorxy = phenotype2vor(phenotype)
%PHENOTYPE2VOR Convert a linear phenotype array to a 
%   Nx2 Voronoi points array.
%
% Syntax:
%   vorxy = phenotype2vor(phenotype)
%
% Description:
%   This function takes a linear array of coordinates and converts it 
%   into a Nx2 array where N is half the length of the input array. 
%   This is useful for genetic algorithms or other optimization methods 
%   that operate on linearized data.
%
% Inputs:
%   phenotype - A 1x2N array where each pair of elements represents the 
%               x (longitude) and y (latitude) coordinates of a point, 
%               consecutively.
%
% Outputs:
%   vorxy - An Nx2 matrix of Voronoi points where the first column 
%           contains longitudes and the second column contains latitudes.
%
% Example:
%   phenotype = [1.5, -0.5, 2.5, -2.5];
%   vorxy = phenotype2vor(phenotype);
%   % Output: vorxy --> [1.5, -0.5; 2.5, -2.5]
%
% See also:
%   reshape

% Number of voronoi points
n = length(phenotype) / 2;

% Re-shape the linear phenotype
vorxy = reshape(phenotype, 2, n)';

end

