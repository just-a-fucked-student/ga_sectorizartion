function [xUniq, totalOcc, realOcc] = findUniqueIntersections(x, isfir)
%FINDUNIQUEINTERSECTIONS Filters and counts unique geographic 
%   intersection points.
%
% Syntax:
%   [xUniq, totalOcc, realOcc] = findUniqueIntersections(x, isfir)
%
% Description:
%   This function identifies unique intersection points from a list of 
%   geographic coordinates, approximates their values to avoid precision 
%   issues, and counts the occurrences of each unique point. 
%   It also calculates a 'real' occurrence count, which adjusts for 
%   potential double counting or geometric multiplicities, depending
%   on the context (e.g., within a flight information region (FIR)).
%
% Inputs:
%   x - An Nx2 array of geographic coordinates (longitude and latitude) 
%       where intersections occur.
%   isfir - A boolean flag indicating whether the intersection points are 
%           within a flight information region (FIR). 
%           This affects how real occurrences are calculated:
%           - true: Each occurrence count is halved, assuming 
%                   bidirectional intersection.
%           - false: Uses a quadratic relationship to adjust the count 
%                    based on potential multiple overlaps or crossings.
%
% Outputs:
%   xUniq - An Mx2 array of unique geographic coordinates, 
%           representing unique intersection points.
%   totalOcc - An Mx1 vector indicating the total number of times 
%              each unique point occurs.
%   realOcc - An Mx1 vector indicating the 'real' number of occurrences, 
%             adjusted for specific conditions such as bidirectional 
%             overlaps or multiple crossings.
%
% See also:
%   unique, accumarray, round, sqrt

% Approximate the values of x (avoids precision issues)
xx = round(1000 * x);

% Get unique elements of the vector, as well as the indexes
[xUniq, ~, j] = unique(xx, 'rows');

% Un-do the approximation
xUniq = xUniq / 1000;

% Vectorized counting of occurrences
totalOcc = accumarray(j, 1);

% Vectorized computation of realOccurence
realOcc = zeros(size(xUniq, 1), 1);

% Directly set real occurence to 1 for rows that occur exactly once
singleOcc = totalOcc == 1;
realOcc(singleOcc) = 1;

% For rows occurring more than once...
manyOcc= ~singleOcc & totalOcc > 1;

% Select type of indicator calculation
if isfir
    % For FIR, divide the total occurrences by 2
    realOcc(manyOcc) = totalOcc(manyOcc) / 2;
else
    % Direct calculation of the positive root for the quadratic equation:
    % x^2 - x - 2*C = 0 (where C is totaloccurence for each row), 
    % the positive root can be simplified to 0.5 + sqrt(0.25 + 2*C).
    realOcc(manyOcc) = 0.5 + sqrt(0.25 + 2 * totalOcc(manyOcc)); 
end

end