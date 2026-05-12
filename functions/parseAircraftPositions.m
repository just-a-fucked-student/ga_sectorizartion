function aircraft = parseAircraftPositions(filename)
%PARSEAIRCRAFTPOSITIONS Parses aircraft positional data from a text file.
%
% Syntax:
%   aircraft = parseAircraftPositions(filename)
%
% Description:
%   This function reads a file containing aircraft positional data and
%   extracts aircraft IDs along with their latitude and longitude 
%   coordinates. 
%   The data is expected to be delimited by spaces. 
%   The function constructs a table with the extracted data.
%
% Inputs:
%   filename - Path to the file containing aircraft positional data. 
%              Each line in the file should contain an aircraft ID 
%              followed by its latitude and longitude as floating-point
%              numbers, separated by spaces.
%
% Outputs:
%   aircraft - A table containing three columns: 
%              'AircraftID', 'Lat', and 'Lon', which represent the 
%              aircraft ID, latitude, and longitude, respectively.
%
% See also:
%   fopen, textscan, fclose, table

% Open the file for reading
fid = fopen(filename, 'rt');
if fid == -1
    error('Cannot open file: %s', filename);
end

% Read the file line by line to extract the raw data
data = textscan(fid, '%s %f %f', 'Delimiter', ' ');
fclose(fid);

% Parse aircraft IDs, latitudes, and longitudes
aircraftIDs = data{1};
latitudes = data{2};
longitudes = data{3};

% Create a table with the parsed data
aircraft = table(...
    string(aircraftIDs), latitudes, longitudes, ...
    'VariableNames', {'AircraftID', 'Lat', 'Lon'});

end
