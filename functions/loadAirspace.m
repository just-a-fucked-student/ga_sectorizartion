function airspace = loadAirspace(fNavWpts, fFir, fAirways, fAC)
%LOADAIRSPACE Load airspace and aircraft traffic data.
%
% Syntax:
%   airspace = loadAirspace(fNavWpts, fFir, fAirways, fAC)
%
% Description:
%   This function loads and processes airspace data, including waypoints, 
%   flight information regions (FIRs), and airways. 
%   It also loads aircraft traffic data and determines aircraft positions 
%   relative to the FIR boundaries.
%   The function returns a structured array containing detailed airspace 
%   and traffic information.
%
% Inputs:
%   fNavWpts - File path for navigation waypoints data.
%   fFir     - File path for flight information region (FIR) data.
%   fAirways - File path for airways data.
%   fAC      - File path for aircraft positions data.
%
% Outputs:
%   airspace - A structure containing the following fields:
%       waypoints        - Parsed waypoint data.
%       airways          - Airways, defined by waypoints.
%       crossAirways     - Intersections of airways.
%       fir              - FIR boundary segments.
%       crossAirwaysFir  - Intersections of airways with the FIR.
%       aircraft         - RAW aircraft positions data (all aircraft).
%       aircraftInFir    - Aircraft positions data within the FIR.
%       axisBounds       - Axis-aligned bounding box for the FIR.
%       vorBounds        - Boundary-Voronoi coordinates.
%
% See also:
%   parseWaypoints, parseODPairs, generateSegments, 
%   findAirwayIntersections, findAirwayFirIntersections, 
%   findVoronoiBounds, inpolygon
%
% MGTA | EETAC/UPC
% 2024

% Load Airspace Data
waypoints = parseWaypoints(fNavWpts);
firOD = parseODPairs(fFir);
fir = generateSegments(firOD, waypoints);
airwaysOD = parseODPairs(fAirways);
airways = generateSegments(airwaysOD, waypoints);
crossAirways = findAirwayIntersections(airways);
crossAirwaysFir = findAirwayFirIntersections(airways, fir);
[vorBounds, axisBounds] = findVoronoiBounds(fir);

% Load Traffic Data
aircraft = parseAircraftPositions(fAC);
idx = inpolygon(aircraft.Lon,aircraft.Lat,fir.OrigLon,fir.OrigLat);
aircraftInFir = aircraft(idx,:);

% Airspace structure
airspace = struct(...
    'waypoints',        waypoints,...
    'airways',          airways,...
    'crossAirways',     crossAirways,...
    'fir',              fir,...
    'crossAirwaysFir',  crossAirwaysFir,...
    'aircraft',         aircraft,...
    'aircraftInFir',    aircraftInFir,...
    'axisBounds',       axisBounds,...
    'vorBounds',        vorBounds...
    );

end

