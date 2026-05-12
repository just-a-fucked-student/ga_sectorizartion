function intersectionPoints = findAirwayFirIntersections(airways, fir)
%FINDAIRWAYFIRINTERSECTIONS Finds intersection points between airways 
%   and FIR boundaries.
%
% Syntax:
%   intersectionPoints = findAirwayFirIntersections(airways, fir)
%
% Description:
%   This function computes the intersection points between airway segments 
%   and the boundaries of a flight information region (FIR). 
%   Each intersection is calculated between one airway segment and 
%   one FIR segment. 
%   The function ensures that each intersection point is listed only once 
%   in the output along with the count of how many times it appears, 
%   adjusted for being within an FIR.
%
% Inputs:
%   airways - A table with the airway segments, including fields 
%             'OrigLon', 'OrigLat', 'DestLon', and 'DestLat', 
%             which are the longitude and latitude of the origin and 
%             destination points of each airway segment.
%   fir - A table with the FIR segments, similar in structure to airways, 
%         containing 'OrigLon', 'OrigLat', 'DestLon', and 'DestLat' 
%         for each segment of the FIR boundary.
%
% Outputs:
%   intersectionPoints - 
%       A table containing the unique geographic coordinates of the
%       intersection points ('Lon', 'Lat') and two additional columns
%       ('Total' and 'Real') indicating the total occurrences of each
%       intersection and the count of real intersections after filtering
%       duplicates and adjusting for FIR-specific considerations.
%
% See also:
%   intersectSegments, findUniqueIntersections, struct, array2table

% Initialize variables to store intersection points
crossAll = [];

% Iterate over each pair of airway and FIR segments
for i = 1:height(fir)
    for j = 1:height(airways)
        
        % Construct segments for the airways
        s1 = struct('A', [fir.OrigLon(i), fir.OrigLat(i)], ...
                    'B', [fir.DestLon(i), fir.DestLat(i)]);
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
[crossUnique, totalOcc, realOcc] = findUniqueIntersections(crossAll, true);

% Create a table from the unique intersection points
intersectionPoints = array2table(...
    [crossUnique, totalOcc, realOcc], ...
    'VariableNames', {'Lon', 'Lat', 'Total', 'Real'});

end
