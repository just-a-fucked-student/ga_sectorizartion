function plotVoronoiSectors(ah, vorx, vory, airspace)
%PLOTVORONOI_SECTORS Adds Voronoi diagram elements to an existing figure.
%
% Syntax:
%   plotVoronoiSectors(ah, vorx, vory, airspace)
%
% Description:
%   This function plots Voronoi cells on an existing axis handle (ah) 
%   using the Voronoi points specified by vorx and vory. 
%   It adds labels to each Voronoi cell and adjusts the viewport 
%   boundaries according to a given airspace structure.
%
% Inputs:
%   ah - Axis handle where the Voronoi diagram will be plotted.
%   vorx - Vector of x-coordinates (longitude) for Voronoi diagram points.
%   vory - Vector of y-coordinates (latitude) for Voronoi diagram points.
%   airspace - Structure containing additional parameters, including 
%              'axisBounds', which specifies the plotting boundaries 
%              as [xmin xmax ymin ymax].
%
% Outputs:
%   None. The function modifies the existing axis specified by ah.
%
% See also:
%   voronoi, text, axis

% Plot voronoi cells
voronoi(ah, vorx, vory);

% Add labels
for i=1:length(vorx)
    text(ah, vorx(i)+0.01, vory(i), num2str(i), ...
        'HorizontalAlignment', 'left', 'fontsize', 18);
end

% Re-adjust viewport boundaries
axis(ah, airspace.axisBounds);

end

