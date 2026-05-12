function ah = plotAirspace(airspace, ah)
%PLOTAIRSPACE Visualizes airspace elements, including waypoints, airways, 
%   intersections and aircraft positions.
%
% Syntax:
%   ah = plotAirspace(airspace, ah)
%
% Description:
%   This function plots a comprehensive visualization of an airspace 
%   layout, including waypoints, flight information regions (FIR), 
%   airways, intersections, and aircraft positions. 
%   If an axis handle is not provided, the function creates a new figure
%   and axis for the plot. 
%   The visualization includes labels, coastlines, and appropriate scaling 
%   and styling for clarity.
%
% Inputs:
%   airspace - A structure containing fields with required data:
%              waypoints, fir, airways, crossAirways, crossAirwaysFir, 
%              aircraftInFir, and axisBounds. 
%              Each field should be a table or array suitable for plotting.
%   ah       - (Optional) Axis handle in which to plot the airspace. 
%              If omitted or empty, a new figure and axis are created.
%
% Outputs:
%   ah - Axis handle in which the airspace elements have been plotted.
%
% See also:
%   plot, text, xlim, ylim, title, xlabel, ylabel

% If empty axes given, create a new figure here
if nargin < 2 || isempty(ah)
    
    % Figure
    figure(); % Create a new figure
    ah = gca; % Current axes
    
    % Styling & stuff
    hold on;
    box on;
    grid on;
    axis equal;
    title(ah, 'Airspace Sectoring');
    xlabel(ah, 'Longitude [deg]');
    ylabel(ah, 'Latitude [deg]');

    % Axis boundaries
    xlim(ah, airspace.axisBounds(1:2));
    ylim(ah, airspace.axisBounds(3:4));

    % Show the Earth coastline contour
    cl = load('data/Coastlines.mat');
    lg = 0.8 * [1,1,1]; % Light grey
    plot(cl.coastlon, cl.coastlat, 'Color', lg);

end

% Plot the waypoints
for i = 1:height(airspace.waypoints)
    lon = airspace.waypoints.Lon(i);
    lat = airspace.waypoints.Lat(i);
    id = airspace.waypoints.ID(i);
    plot(ah, lon, lat, 'r.', 'MarkerSize', 12);
    text(ah, lon + 0.008, lat, id, ...
        'HorizontalAlignment', 'left', 'FontSize', 8);
end

% Plot the FIR
for i = 1:height(airspace.fir)
    origLon = airspace.fir.OrigLon(i);
    origLat = airspace.fir.OrigLat(i);
    destLon = airspace.fir.DestLon(i);
    destLat = airspace.fir.DestLat(i);
    plot(ah, [origLon, destLon], [origLat, destLat], ...
        'k-', 'LineWidth', 1);
end

% Plot the airways
for i = 1:height(airspace.airways)
    origLon = airspace.airways.OrigLon(i);
    origLat = airspace.airways.OrigLat(i);
    destLon = airspace.airways.DestLon(i);
    destLat = airspace.airways.DestLat(i);
    plot(ah, [origLon, destLon], [origLat, destLat], ...
        'c-', 'LineWidth', 1);
end

% Plot the airways intersection points
for k = 1:height(airspace.crossAirways)
    lon = airspace.crossAirways.Lon(k);
    lat = airspace.crossAirways.Lat(k);
    plot(ah, lon, lat, 'bx', 'MarkerSize', 8);
end

% Plot the airways-FIR intersection points
for k = 1:height(airspace.crossAirwaysFir)
    lon = airspace.crossAirwaysFir.Lon(k);
    lat = airspace.crossAirwaysFir.Lat(k);
    plot(ah, lon, lat, 'ms', 'MarkerSize', 5);
end

% Plot the aircraft positions
for i = 1:height(airspace.aircraftInFir)
    lon = airspace.aircraftInFir.Lon(i);
    lat = airspace.aircraftInFir.Lat(i);
    plot(ah, lon, lat, 'r+', 'MarkerSize', 14);
end

% Plot the Voronoid bounds
% for i = 1:size(airspace.vorBounds,2)
%     lon = airspace.vorBounds(:,1);
%     lat = airspace.vorBounds(:,2);
%     plot(ah, lon, lat, 'gp', 'MarkerSize', 12);
% end

% Plot the axis bounds
% for i = 1:length(airspace.axisBounds)
%     min_x = airspace.axisBounds(1);
%     max_x = airspace.axisBounds(2);
%     min_y = airspace.axisBounds(3);
%     max_y = airspace.axisBounds(4);
%     w = max_x - min_x;
%     h = max_y - min_y;
%     rectangle(ah, 'Position', [min_x, min_y, w, h], ...
%         'EdgeColor', 'green', 'LineWidth', 2, 'LineStyle', '-');
% end

% Process all pending drawing operations
drawnow;

end
