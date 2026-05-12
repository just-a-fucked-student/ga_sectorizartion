function phenotype = vor2phenotype(vorxy)
%VOR2PHENOTYPE Convert a Nx2 Voronoi points array to a 
%   linear phenotype array.
%
% Syntax:
%   phenotype = vor2phenotype(vorxy)
%
% Description:
%   This function takes a Nx2 array of Voronoi points, where each row 
%   contains the longitude and latitude of a point, and converts it into 
%   a linear array.
%   This linear array format is typically used in genetic algorithms or
%   other optimization methods that require phenotype representations.
%
% Inputs:
%   vorxy - An Nx2 matrix of Voronoi points where the first column contains
%           longitudes and the second column contains latitudes.
%
% Outputs:
%   phenotype - A 1x2N array where the coordinates of the points are
%               alternated as longitude and latitude.
%
% Example:
%   vorxy = [1.5, -0.5; 2.5, -2.5];
%   phenotype = vor2phenotype(vorxy);
%   % Output: phenotype --> [1.5, -0.5, 2.5, -2.5]
%
% See also:
%   reshape

% Linearise the voronoi array
phenotype = reshape(vorxy', 1, []);

end

