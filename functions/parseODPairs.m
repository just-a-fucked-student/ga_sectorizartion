function odPairs = parseODPairs(filename)
%PARSEODPAIRS Parses origin-destination pairs from a specified file.
%
% Syntax:
%   odPairs = parseODPairs(filename)
%
% Description:
%   This function reads a file to extract pairs of origin and destination 
%   waypoints.
%   Each line in the file is expected to contain two waypoint identifiers, 
%   separated by a space, representing an origin and a destination. 
%   The function constructs a table with the extracted pairs.
%
% Inputs:
%   filename - Path to the file containing origin and destination data. 
%              Each line should have two identifiers separated by spaces.
%
% Outputs:
%   odPairs - A table containing two columns: 'Orig' and 'Dest', 
%             which represent the origin and destination waypoint 
%             identifiers, respectively.
%
% See also:
%   fopen, textscan, fclose

% Open the file for reading
fid = fopen(filename, 'rt');
if fid == -1
    error('Cannot open file: %s', filename);
end

% Read the file line by line to extract origin and destination waypoints
data = textscan(fid, '%s %s', 'Delimiter', ' ');
fclose(fid);

% Extract origins and destinations
origins = data{1};
destinations = data{2};

% Create a table with the parsed data
odPairs = table(...
    string(origins), string(destinations), ...
    'VariableNames', {'Orig', 'Dest'});

end
