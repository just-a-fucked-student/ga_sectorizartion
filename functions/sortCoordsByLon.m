function v_sorted = sortCoordsByLon(v)
%SORTCOORDSBYLON Sorts a vector of longitude/latitude pairs by longitude.
%
%   v_sorted = SORTCOORDSBYLON(v) takes a 1D vector of coordinates 
%   arranged as [lon1, lat1, lon2, lat2, ..., lonN, latN] and returns 
%   a vector of the same format, but sorted in ascending order by the 
%   longitude values.
%
%   INPUT:
%       v - A 1 x (2N) vector of coordinates, where N is the number of points.
%           Each pair (lon, lat) represents the longitude and latitude 
%           of a point.
%
%   OUTPUT:
%       v_sorted - A 1 x (2N) vector of sorted coordinates.
%
%   EXAMPLE:
%       v = [30 10 20 5 40 2];
%       v_sorted = sortCoordsByLon(v);
%       % v_sorted = [20 5 30 10 40 2]

    % Validate input
    if ~isvector(v) || mod(length(v), 2) ~= 0
        error(['Input must be a 1D vector with even length: ' ...
            '[lon1, lat1, lon2, lat2, ..., lonN, latN].']);
    end
    
    % Number of points
    N = length(v) / 2;
    
    % Reshape into an N-by-2 matrix:
    % Each row corresponds to [lon, lat]
    coords = reshape(v, 2, N)';
    
    % Sort by longitude (first column)
    coords_sorted = sortrows(coords, 1);
    
    % Reshape back into the original format
    v_sorted = coords_sorted';
    v_sorted = v_sorted(:)';

end

