function comp = complexityFunction(vor, airspace)
%COMPLEXITYFUNCTION Computes complexity parameters for airspace sectoring.
%
% Syntax:
%   comp = complexityFunction(vor, airspace)
%
% Description:
%   This function calculates various metrics to assess the complexity 
%   of sectors defined by Voronoi diagrams. 
%   These metrics include the number of aircraft in each sector, 
%   the number of intersections between sectors and flight information 
%   regions (FIRs), and other related measurements.
%
% Inputs:
%   vor - Matrix of Voronoi points coordinates used to define sectors.
%   airspace - Struct containing airspace data, including 
%              aircraft positions, FIR boundaries, and details of 
%              airways and their intersections.
%
% Returns:
%   comp - Structure containing complexity metrics for each sector:
%     - aircraftInSector: Number of aircraft within each sector.
%     - firTransfers: Number of intersection points between airways and FIR within sectors.
%     - sectorTransfers: Number of intersection points between airways and each sector.
%     - airwaysIntersections: Number of intersections between different airways within sectors.
%     - airwaysLength: Total length of airways contained within each sector [km].
%     - sectorArea: Area of each sector [km^2].
%
% See also:
%   generateVoronoiNoInf, inpolygon, polyshape, polyarea, 
%   intersectSegmentConvPolygon, segmentLength

% Generate Voronoi diagram from the input coordinates
% Ignores all voronoi cells with points at infinity
[vorVertices, vorCells] = generateVoronoiNoInf(vor);

% Preallocate arrays of cost
n = size(vorCells,1);
aircraftInSector = zeros(n,1);
firTransfers = zeros(n,1);
sectorTransfers = zeros(n,1);
airwaysIntersections = zeros(n,1);
airwaysLength = zeros(n,1);
sectorArea = zeros(n,1);

% For each voronoi cell...
for i=1:n

    % Current voronoi cell (sector)
    vci = vorCells{i,:};
    vcix = vorVertices(vci,1);
    vciy = vorVertices(vci,2);

    % Aircraft inside the sector
    idx = inpolygon( ...
        airspace.aircraftInFir.Lon, ...
        airspace.aircraftInFir.Lat, ...
        vcix, vciy);
    idx_in = find(idx);
    aircraftInSector(i) = size(idx_in,1);
    
    % FIR intersection points (transfers)
    idx = inpolygon(...
        airspace.crossAirwaysFir.Lon, ...
        airspace.crossAirwaysFir.Lat, ...
        vcix, vciy);
    firTransfers(i) = airspace.crossAirwaysFir.Real' * idx;
    
    % Airways intersection points
    idx = inpolygon( ...
        airspace.crossAirways.Lon, ...
        airspace.crossAirways.Lat, ...
        vcix, vciy);
    airwaysIntersections(i) = airspace.crossAirways.Real' * idx;
     
    % Airways/Sector intersection (transfer points) 
    % + length of airways within each sector
    countTransfers = 0;
    countLength = 0;
    for j=1:height(airspace.airways)
        s1 = struct('A', [airspace.airways.OrigLon(j), ...
                          airspace.airways.OrigLat(j)], ...
                    'B', [airspace.airways.DestLon(j), ...
                          airspace.airways.DestLat(j)]);
        inters = intersectSegmentConvPolygon(s1, [vcix, vciy]);
        if inters.n ~= -1
            countTransfers = countTransfers + inters.n;
            countLength = countLength + segmentLengthGeodesic(inters);
        end
    end
    sectorTransfers(i) = countTransfers; % Number of transfer points 
    airwaysLength(i) = countLength; % Lengths of inner airways [km]

    % Compute area of sector 
    poly1 = polyshape(vcix, vciy, ...
        'Simplify', true, 'KeepCollinearPoints', true); % Sector
    poly2 = polyshape([airspace.fir.OrigLon, airspace.fir.OrigLat], ...
        'Simplify', true, 'KeepCollinearPoints', true); % FIR
    polyInt = intersect(poly1, poly2); % FIR & Sector intersection (F&S)
    sectorAreaDeg = polyarea(...
        polyInt.Vertices(:,1), polyInt.Vertices(:,2)); % F&S Area [deg2]
    meanLat = mean(polyInt.Vertices(:,2)); % Mean latitude of the vertices
    if isnan(meanLat), meanLat = 0; end % This happens with empty sectors
    sectorArea(i) = convertAreaDeg2ToKm2(sectorAreaDeg, meanLat); % [km2]

end

% Complexity struct
comp = struct(...
    'aircraftInSector', aircraftInSector, ...
    'firTransfers', firTransfers, ...
    'sectorTransfers', sectorTransfers,...
    'airwaysIntersections', airwaysIntersections, ...
    'airwaysLength', airwaysLength, ...
    'sectorArea', sectorArea);

end

