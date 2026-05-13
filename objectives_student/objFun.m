function [objV, obj1, obj2, obj3, obj4] = objFun(phenotypes)
% Función que calcula la carga de trabajo en la gestión de aviones por sectores.
% Devuelve valores de objetivos para optimizar la sectorización con Voronoi.

%objFun Evaluates the sectoring workload for aircraft management.
%
% Syntax:
%   [objV, obj1, obj2, obj3, obj4] = objFun(phenotypes)
%
% Description:
%   This function computes multiple workload-related objective values 
%   for a given set of phenotypes, which define Voronoi sectors in an 
%   airspace management scenario.
%   It assesses the complexity of each sector configuration and calculates 
%   specific workload metrics.
%
% Inputs:
%   phenotypes - A matrix where each row represents a set of coordinates
%                alternating between longitudes and latitudes, 
%                defining the Voronoi points for sectorization.
%
% Outputs:
%   objV  - Vector of aggregated objective values for each phenotype.
%   obj1, obj2, obj3, obj4 - Vectors of objective metrics for each 
%                            phenotype, typically related to workload 
%                            balance among sectors.
%
% Notes:
%   The function loads an airspace data set containing all the required 
%   airspace-related data.
%
% See also:
%   complexityFunction, voronoi, std, mean

% Cargar datos del espacio aéreo guardados
airspace = load(fullfile('data','airspace.mat'));

% Número de configuraciones a evaluar
nPhenos = size(phenotypes,1);

% Preparar variables para guardar los resultados
objV = zeros(nPhenos, 1);
obj1 = zeros(nPhenos, 1);
obj2 = zeros(nPhenos, 1);
obj3 = zeros(nPhenos, 1);
obj4 = zeros(nPhenos, 1);

% Calcular costos para cada configuración
for i=1:nPhenos

    % Convertir la configuración a puntos Voronoi
    vorxy = phenotype2vor(phenotypes(i,:));
    
    % Add boundary voronoi (this avoids infinite sectors near FIR)
    vor = [vorxy; airspace.vorBounds]; 

    % Calcular la complejidad de cada sector
    comp = complexityFunction(vor, airspace);
    
    % Workload related to Background tasks: aircraft balance across sectors
    obj1(i,1) = std(comp.aircraftInSector);
    % Workload related to Transition tasks: FIR transfer balance
    obj2(i,1) = std(comp.firTransfers);
    % Workload related to Recurring tasks: airway-sector transfer balance
    obj3(i,1) = std(comp.sectorTransfers);
    % Workload related to Conflict tasks: RSD de total airway intersections
    obj4(i,1) = std(comp.airwaysIntersections) / (mean(comp.airwaysIntersections)+1e-6);
    
    % Objetivo principal: minimizar intersecciones de airways
    objV(i,1) = obj4(i,1);

end

end
