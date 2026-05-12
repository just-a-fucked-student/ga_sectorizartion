function segments = generateSegments(odPairs, waypoints)
%GENERATESEGMENTS Creates segments based on origin-destination pairs 
%   and waypoints data.
%
% Syntax:
%   segments = generateSegments(odPairs, waypoints)
%
% Description:
%   This function takes a table of origin-destination pairs and a table 
%   of waypoints, and generates a new table that includes the geographic 
%   coordinates of each segment.
%   Each segment is defined by the latitude and longitude of its origin 
%   and destination waypoints. 
%   The function handles missing waypoints by assigning NaN values 
%   and filters out such incomplete segments.
%
% Inputs:
%   odPairs - A table with two columns, 'Orig' and 'Dest', containing IDs 
%             of origin and destination waypoints for each segment.
%   waypoints - A table containing waypoint IDs and their corresponding 
%               geographic coordinates ('Lat' and 'Lon'). 
%               Each waypoint ID should be unique.
%
% Outputs:
%   segments - A table with six columns: 
%              'OrigID', 'OrigLat', 'OrigLon', 
%              'DestID', 'DestLat', 'DestLon'.
%              This table represents the complete segments where both
%              origin and destination waypoints have valid coordinates.
%
% See also:
%   find, isnan, table

% Initialize arrays for latitude and longitude
n = height(odPairs);
origLats = zeros(n, 1);
origLons = zeros(n, 1);
destLats = zeros(n, 1);
destLons = zeros(n, 1);

% Iterate through each airway to find corresponding waypoint data
for i = 1:n

    % Find the index of the Origin waypoint in waypoints
    origIdx = find(waypoints.ID == odPairs.Orig(i));

    % Find the index of the Destination waypoint in waypoints
    destIdx = find(waypoints.ID == odPairs.Dest(i));

    % If both Origin and Destination are found in waypoints, 
    % assign their latitudes and longitudes
    if ~isempty(origIdx) && ~isempty(destIdx)
        origLats(i) = waypoints.Lat(origIdx);
        origLons(i) = waypoints.Lon(origIdx);
        destLats(i) = waypoints.Lat(destIdx);
        destLons(i) = waypoints.Lon(destIdx);
    else
        % Mark airways with missing waypoints with NaNs
        origLats(i) = NaN;
        origLons(i) = NaN;
        destLats(i) = NaN;
        destLons(i) = NaN;
    end

end

% Filter out segments with missing waypoints
validSegments = ~isnan(origLats) & ~isnan(destLats);
seg = odPairs(validSegments, :);

% Add latitude and longitude data to the segments struct
seg.OrigLat = origLats(validSegments);
seg.OrigLon = origLons(validSegments);
seg.DestLat = destLats(validSegments);
seg.DestLon = destLons(validSegments);

% Convert the table to have structured fields for Origin and Destination
segments = table(...
    seg.Orig, seg.OrigLat, seg.OrigLon, ...
    seg.Dest, seg.DestLat, seg.DestLon, ...
    'VariableNames', {'OrigID', 'OrigLat', 'OrigLon', ...
                      'DestID', 'DestLat', 'DestLon'});

end
