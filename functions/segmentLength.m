function d = segmentLength(s)
%SEGMENTLENGTH Calculates the length of a line segment.
%
% Syntax:
%   d = segmentLength(s)
%
% Description:
%   This function computes the Euclidean distance between two points 
%   that define a line segment. 
%   The points are given in a structure that includes fields 'A' and 'B', 
%   each a two-element vector representing the coordinates of the segment
%   endpoints.
%
% Inputs:
%   s - A struct with fields 'A' and 'B', each a two-element vector 
%       representing the endpoints [x, y] of the segment.
%
% Return:
%   d - The length of the segment, calculated as the Euclidean distance
%       between the points 'A' and 'B'.
%
% Example of use:
%   s = struct('A', [2, 3], 'B', [4, 2]);
%   l = segmentLength(s);
%   % Output: l --> 2.2361
%
% See also:
%   norm

vectAB = s.B - s.A; % Vector
d = norm(vectAB); % Length

end

