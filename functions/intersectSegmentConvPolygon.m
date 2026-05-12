function inters = intersectSegmentConvPolygon(s, p)
%INTERSECTSEGMENTCONVPOLYGON Finds intersections between a segment 
%   and a convex polygon.
%
% Syntax:
%   inters = intersectSegmentConvPolygon(s, p)
%
% Description:
%   This function calculates the intersection points of a line segment 
%   with a convex polygon.
%   The segment may intersect the polygon at zero, one, or two points, 
%   or it may lie entirely within the polygon. 
%   The function returns a structure describing the nature and details
%   of the intersection.
%
% Inputs:
%   s - A struct with fields 'A' and 'B', each a two-element vector 
%       representing the endpoints [x, y] of the segment.
%   p - An Nx2 matrix where each row represents the vertices 
%       [x1, y1; x2, y2; ...; xN, yN] of the polygon. 
%       The polygon is assumed to be convex and its vertices are ordered
%       either clockwise or counterclockwise.
%
% Return:
%   inters - A struct containing:
%       A, B - The endpoints [x, y] of the intersecting segment or 
%              point(s) of intersection.
%       n - The number of intersection points:
%           - 2: If there are two distinct intersection points.
%           - 1: If there is exactly one intersection point.
%           - 0: If the segment lies entirely within the polygon.
%           - -1: If the segment does not intersect the polygon.
%
% Example 1:
%   s=struct('A',[2,3],'B',[4,2])
%   p=[-3,0; 0,3; 3,0; 0,-1];
%   inters=intersectSegmentConvPolygon(s,p)
%   inters = 
%    A: []
%    B: []
%    n: -1
%
% Example 2:
%   p=[-3,0; 0,3; 3,0; 0,-1];
%   s=struct('A',[0,0],'B',[4,2]);
%   inters=intersectSegmentConvPolygon(s,p)
%   inters = 
%    A: [2 1]
%    B: [0 0]
%    n: 1
%
% Example 3:
%   p=[-3,0; 0,3; 3,0; 0,-1];
%   s=struct('A',[0,0],'B',[0,1]);
%   inters=intersectSegmentConvPolygon(s,p)
%   inters = 
%    A: [0 0]
%    B: [0 1]
%    n: 0
%
% Example 4:
%   p=[-3,0; 0,3; 3,0; 0,-1];
%   s=struct('A',[-2,3],'B',[4,2]);
%   inters=intersectSegmentConvPolygon(s,p)
%   inters = 
%    A: [-0.2857 2.7143]
%    B: [0.4000 2.6000]
%    n: 2
%
% See also:
%   inpolygon, intersectSegments

% Initialise output struct; assuming no intersection by default
inters = struct('A', [], 'B', [], 'n', -1);

% Stuff
in1 = inpolygon(s.A(1), s.A(2), p(:,1), p(:,2));
in2 = inpolygon(s.B(1), s.B(2), p(:,1), p(:,2));

% Segment AB is all included within polygon
if in1 == 1 && in2 == 1
    n = 0;
    inters = struct('A', s.A, 'B', s.B, 'n', n);
    return
end

pointAux = zeros(size(p,1)-1,2);
k=1;
for i=1:size(p,1)-1
    s1 = struct('A',p(i,:), 'B', p(i+1,:));
    auxint = intersectSegments(s1, s);
    if(size(auxint,1)~=0)
      pointAux(k,:) = auxint;
      k=k+1;
    end
end    
point = pointAux(1:k-1,:);

s1 = struct('A',p(i+1,:), 'B', p(1,:));

inter = [point; intersectSegments(s1, s)];

n = size(inter,1);
if n == 0
    n = -1;
    inters = struct('A', [], 'B', [], 'n', n);
elseif n == 1
    if in1 == 1
        inters = struct('A', inter(1,:), 'B', s.A, 'n', n);
    elseif in2 == 1
        inters = struct('A', inter(1,:), 'B', s.B, 'n', n);   
    end
elseif n == 2
    inters = struct('A', inter(1,:), 'B', inter(2,:), 'n', n);
end

end

