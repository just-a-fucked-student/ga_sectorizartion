function lengthKm = segmentLengthGeodesic(s)
%segmentLengthGeodesic Compute the length of a geodesic segment 
%   from degrees to kilometers.
%
% Syntax:
%   lengthKm = segmentLengthGeodesic(s)
%
% Description:
%   This function calculates the geodesic length of a segment defined by
%   two geographic points (latitude and longitude in degrees) and converts
%   this length to kilometers. 
%   The Earth is approximated as an ellipsoid, and the Haversine formula 
%   is used for the calculation.
%
% Inputs:
%   s - A struct with fields 'A' and 'B', each a two-element vector 
%       representing the endpoints [lon, lat] of the segment.
%
% Outputs:
%   lengthKm - Length of the segment in kilometers.
%
% Example:
%   s.A = [-118.2, 34.0]; % Los Angeles, CA
%   s.B = [-074.0, 40.7]; % New York, NY
%   lengthKm = segmentLengthGeodesic(s);
%   disp(['The length of the segment is ', num2str(length_km), ' km']);
%
% Note:
%   The calculation is based on the Haversine formula, which is suitable
%   for small to medium distances. 
%   For very long distances or high-precision requirements, other methods 
%   like Vincenty's formula might be more appropriate.
%
% See also:
%   COSD, SIND, ACOSD

% Earth's radius in kilometers (mean radius)
R = 6371;

% Vector components
lon1 = s.A(1);
lat1 = s.A(2);
lon2 = s.B(1);
lat2 = s.B(2);

% Delta coordinates in degrees
dLat = lat2 - lat1;
dLon = lon2 - lon1;

% Convert degrees to radians
dLat = deg2rad(dLat);
dLon = deg2rad(dLon);
lat1 = deg2rad(lat1);
lat2 = deg2rad(lat2);

% Haversine formula
a = sin(dLat/2)^2 + cos(lat1) * cos(lat2) * sin(dLon/2)^2;
c = 2 * atan2(sqrt(a), sqrt(1-a));
lengthKm = R * c;

end
