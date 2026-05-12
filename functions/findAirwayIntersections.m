function intersectionPoints = findAirwayIntersections(airways)
%FINDAIRWAYINTERSECTIONS Finds intersection points between multiple 
%   airway segments.
%
% Syntax:
%   intersectionPoints = findAirwayIntersections(airways)
%
% Description:
%   This function computes the intersection points between all pairs of 
%   airway segments provided in the input table. 
%   Each segment is defined by its origin and destination coordinates. 
%   The function identifies intersections and ensures that each unique
%   intersection point is only listed once in the output along with the 
%   count of how many times it appears.
%
% Inputs:
%   airways - A table with the airway segments, including fields 
%             'OrigLon', 'OrigLat', 'DestLon', and 'DestLat', 
%             which are the longitude and latitude of the origin and 
%             destination points of each airway segment.
%
% Outputs:
%   intersectionPoints - 
%       A table containing the unique geographic coordinates of the 
%       intersection points ('Lon', 'Lat') and two additional columns
%       ('Total' and 'Real') indicating the total occurrences of each 
%       intersection and the count of real intersections after filtering 
%       duplicates.
%
% See also:
%   intersectSegments, findUniqueIntersections, struct, array2table

% Initialize variables to store intersection points
crossAll = [];

% Iterate over each pair of airways
for i = 1:height(airways)-1
    for j = i+1:height(airways)
        
        % Construct segments for the airways
        s1 = struct('A', [airways.OrigLon(i), airways.OrigLat(i)], ...
                    'B', [airways.DestLon(i), airways.DestLat(i)]);
        s2 = struct('A', [airways.OrigLon(j), airways.OrigLat(j)], ...
                    'B', [airways.DestLon(j), airways.DestLat(j)]);
        
        % Calculate intersection
        point = intersectSegments(s1, s2);
        
        % If there's an intersection, add it to the list
        if ~isempty(point)
            crossAll = [crossAll; point];
        end

    end
end

% Remove duplicate intersections and count occurrences
[crossUnique, totalOcc, realOcc] = findUniqueIntersections(crossAll, false);

% Create a table from the unique intersection points
intersectionPoints = array2table(...
    [crossUnique, totalOcc, realOcc], ...
    'VariableNames', {'Lon', 'Lat', 'Total', 'Real'});

end
