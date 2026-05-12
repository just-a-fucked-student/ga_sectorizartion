function waypointsTable = parseWaypoints(filename)
%PARSEWAYPOINTS Parses waypoint data from a specified file.
%
% Syntax:
%   waypointsTable = parseWaypoints(filename)
%
% Description:
%   This function reads waypoint data from a file and converts 
%   latitude and longitude coordinates from DDDMMSS.SX format 
%   (Degrees, Minutes, Seconds, and Hemisphere) to decimal degrees format. 
%   It then constructs a table with the waypoint IDs and their 
%   corresponding decimal latitude and longitude values.
%
% Inputs:
%   filename - Path to the file containing waypoint data in the format: 
%              ID DDDMMSS.SX DDDMMSS.SX.
%
% Outputs:
%   waypointsTable - A table containing three columns: 
%                    'ID', 'Lat', and 'Lon', which represent 
%                    waypoint ID, decimal latitude, and decimal longitude,
%                    respectively.
%
% See also:
%   fopen, textscan, fclose, convertToDecimal

% Open the file for reading
fid = fopen(filename, 'rt');
if fid == -1
    error('Cannot open file: %s', filename);
end

% Prepare to read the file line by line
data = textscan(fid, '%s %s %s', 'Delimiter', ' ');
fclose(fid);

% Extract waypoint IDs, latitudes, and longitudes
waypointIDs = data{1};
lats = data{2};
lons = data{3};

% Convert latitudes and longitudes from DDMMSSX to decimal degrees
decimalLats = zeros(size(lats));
decimalLons = zeros(size(lons));
for i = 1:length(lats)
    decimalLats(i) = convertToDecimal(lats{i});
    decimalLons(i) = convertToDecimal(lons{i});
end

% Create a table with the parsed data
waypointsTable = table(...
    string(waypointIDs), decimalLats, decimalLons, ...
    'VariableNames', {'ID', 'Lat', 'Lon'});

end

function decimalDegree = convertToDecimal(dms)
%CONVERTTODECIMAL Converts geographic coordinates from DDDMMSS.SX format to decimal degrees.
%
% Syntax:
%   decimalDegree = convertToDecimal(dms)
%
% Description:
%   Converts a single coordinate from DDDMMSS.SX format, 
%   where DD represents degrees, MM represents minutes, 
%   SS represents seconds, and SX indicates direction (N, S, E, W),
%   to a decimal degree format. 
%   The result considers the hemisphere to apply the appropriate sign 
%   to the decimal degree value.
%
% Inputs:
%   dms - String containing a coordinate in DDDMMSS.SX format.
%
% Outputs:
%   decimalDegree - Double representing the coordinate in decimal degrees.
%
% See also:
%   str2double

% Convert DDDMMSS.SX format to decimal degrees
degrees = str2double(dms(1:end-7));
minutes = str2double(dms(end-6:end-5));
seconds = str2double(dms(end-4:end-1));

% Determine direction multiplier
direction = dms(end);
if direction == 'N' || direction == 'E'
    multiplier = 1;
else
    multiplier = -1;
end

% Convert to decimal degrees
decimalDegree = multiplier * (degrees + minutes / 60 + seconds / 3600);

end

