function point = intersectSegments(s1, s2)
%INTERSECTSEGMENTS Finds the intersection point of two line segments.
%
% Syntax:
%   point = intersectSegments(s1, s2)
%
% Description:
%   This function calculates the intersection point of two line segments 
%   defined by the endpoints in two structures s1 and s2. 
%   Each structure contains fields 'A' and 'B' which are vectors denoting 
%   the coordinates of the segment endpoints.
%   The function returns the intersection point as a vector [x, y]. 
%   If the segments do not intersect, the function returns an empty array.
%
% Inputs:
%   s1 - A structure with fields 'A' and 'B' representing the endpoints 
%        of the first segment. Each field is a vector [x, y].
%   s2 - A structure with fields 'A' and 'B' representing the endpoints 
%        of the second segment. Each field is a vector [x, y].
%
% Return:
%   point - A vector containing the intersection point [x, y] 
%           if the segments intersect; otherwise, an empty vector.
%
% Example of use:
%   s1 = struct('A', [1, 4], 'B', [4, 1]);
%   s2 = struct('A', [4, 1], 'B', [4, 0]);
%   p = intersectSegments(s1, s2);
%   % Output: p --> [3, 2]
%
% See also:
%   struct

% Small tolerance, to account for numerical imprecisions
epsilon = 1E-9;

% Preemptively assume empty intersection point
point = [];

% Vector representations for the segments and their relative positions
vectAB = s1.B - s1.A;
vectAC = s2.A - s1.A;
vectCD = s2.B - s2.A;

% Determinant d, calculated from vectAB and vectCD.
% This determinant is crucial as it helps in identifying 
% if the two segments are parallel (d==0)
d = vectAB(1)*vectCD(2) - vectCD(1)*vectAB(2);

% If the segments are parallel --> they do not intersect
if d == 0
    return;
end

% Parameters of the line equations in their vector form, 
% indicating the intersection point relative to the segments s1 and s2
l1 = (vectAC(1)*vectCD(2) - vectCD(1)*vectAC(2)) / d;
l2 = (vectAC(1)*vectAB(2) - vectAB(1)*vectAC(2)) / d;

% Check if the intersection point lies within the bounds of the segments
ub = l1 <= 1+epsilon && l2 <= 1+epsilon;
lb = l1 >= 0-epsilon && l2 >= 0-epsilon;
intersects = ub && lb;

% If the segments intersect, find the intersection point
if intersects
    point = s1.A + l1 * vectAB;
end

end
