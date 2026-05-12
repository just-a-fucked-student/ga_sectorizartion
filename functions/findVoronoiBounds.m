function [vorBounds, axisBounds] = findVoronoiBounds(fir)
%FINDVORONOIBOUNDS Calculates extended bounds for Voronoi diagram 
%   generation based on FIR boundaries.
%
% Syntax:
%   [vorBounds, axisBounds] = findVoronoiBounds(fir)
%
% Description:
%   This function computes extended geographical bounds for generating 
%   Voronoi diagrams and for plotting purposes based on the coordinates 
%   of a flight information region (FIR).
%   The function defines an offset to extend the bounds beyond the FIR's 
%   actual boundary to ensure full coverage and visualization quality. 
%   The output includes two sets of bounds: one for axis-aligned plotting 
%   and one specifically configured for Voronoi diagram generation 
%   in optimization processes.
%
% Inputs:
%   fir - A table containing the longitude and latitude of the FIR 
%         boundaries, specifically columns 'OrigLon' and 'OrigLat', 
%         representing the coordinates of FIR segments.
%
% Outputs:
%   vorBounds - A 4x2 matrix of coordinates that define the corners of the 
%               extended area for Voronoi diagram generation. 
%               These points are strategically placed far outside the 
%               FIR boundary to confine the inner Voronoi cells for cost 
%               computation.
%   axisBounds - A 1x4 vector [minx, maxx, miny, maxy] that defines the 
%                bounds for axis-aligned plotting. 
%                This is used primarily for graphical displays and ensures 
%                that all relevant FIR data points are included within the
%                plot view.
%
% See also:
%   voronoin, plot

% Define offset distance
km2deg = 0.008983;
offset = 100 * km2deg;

% Find minimum and maximum values of FIR boundaries
minx = min(fir.OrigLon) - offset;
maxx = max(fir.OrigLon) + offset;
miny = min(fir.OrigLat) - offset;
maxy = max(fir.OrigLat) + offset;

% Bounds for axis (plotting, mainly)
axisBounds = [minx, maxx, miny, maxy];

% Bounds for Voronoi generation during optimisation
% These are points that will be added to the list of voronoi points
% The purpose is to confine the inner voronoi cells for cost computation
vorBounds = [...
    minx - 10 * offset, (maxy+miny)/2; ...
    maxx + 10 * offset, (maxy+miny)/2; ...
    (maxx + minx)/2, miny - 10 * offset; ...
    (maxx + minx)/2, maxy + 10 * offset];

end

