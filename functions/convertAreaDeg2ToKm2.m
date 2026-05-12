function area_km2 = convertAreaDeg2ToKm2(areaDeg2, meanLat)
%CONVERTAREADEG2TOKM2 Convert area from square degrees to square km.
%
% Syntax:
%   areaKm2 = convertAreaDeg2ToKm2(areaDeg2, meanLat)
%
% Description:
%   This function converts an area from square degrees to square kilometers
%   based on the provided mean latitude. 
%   The conversion accounts for the change in the length of a degree 
%   of longitude with latitude.
%
% Inputs:
%   areaDeg2  - Area in square degrees.
%   meanLat   - Mean latitude of the area in degrees.
%
% Outputs:
%   areaKm2   - Converted area in square kilometers.
%
% Example:
%   areaDeg2 = 0.1; % Area in square degrees
%   meanLat = 41.5; % Mean latitude in degrees
%   areaKm2 = convertAreaDeg2ToKm2(areaDeg2, meanLat);
%   disp(['The area in square kilometers is ', num2str(areaKm2)]);
%
% Note:
%   This conversion uses an approximation that assumes the mean latitude
%   does not change significantly across the region. For large regions or
%   those spanning a wide range of latitudes, this method may introduce
%   error.
%
% See also:
%   cosd, polyarea

% Change in the length of a degree of longitude with latitude.
conversionFactor = (111^2) * cosd(meanLat);

% Area conversion
area_km2 = areaDeg2 * conversionFactor;

end
