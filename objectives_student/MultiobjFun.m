function [MobjV, obj1, obj2, obj3, obj4] = MultiobjFun(phenotypes)
% Función para calcular múltiples objetivos en la sectorización.
% Devuelve dos objetivos: intersecciones y balance de aviones.

%MultiobjFun Evaluates multiple objectives for sectorization.
%
% Syntax:
%   [MobjV, obj1, obj2, obj3, obj4] = MultiobjFun(phenotypes)
%
% Description:
%   This function computes a bi-objective cost for a set of phenotypes.
%   It returns both the airway intersections cost and a workload balance
%   metric to be used by a multi-objective GA.
%
% Inputs:
%   phenotypes - A matrix where each row represents a set of coordinates
%                alternating between longitudes and latitudes.
%
% Outputs:
%   MobjV - Matrix of objective values [nPhenotypes x 2].
%   obj1   - Aircraft distribution balance metric.
%   obj2   - FIR transfer balance metric.
%   obj3   - Sector transfer balance metric.
%   obj4   - Total airway intersections cost.

% Cargar datos del espacio aéreo
airspace = load(fullfile('data','airspace.mat'));

% Número de configuraciones
nPhenos = size(phenotypes,1);

% Preparar variables para resultados
MobjV = zeros(nPhenos, 2);
obj1 = zeros(nPhenos, 1);
obj2 = zeros(nPhenos, 1);
obj3 = zeros(nPhenos, 1);
obj4 = zeros(nPhenos, 1);

for i = 1:nPhenos
    % Convertir configuración a puntos Voronoi
    vorxy = phenotype2vor(phenotypes(i,:));
    % Agregar límites para evitar sectores infinitos
    vor = [vorxy; airspace.vorBounds];

    % Calcular complejidad de sectores
    comp = complexityFunction(vor, airspace);

    % Calcular métricas de carga
    obj1(i,1) = std(comp.aircraftInSector);
    obj2(i,1) = std(comp.firTransfers);
    obj3(i,1) = std(comp.sectorTransfers);
    obj4(i,1) = sum(comp.airwaysIntersections);

    % Vector de dos objetivos: intersecciones y balance de aviones
    MobjV(i,:) = [obj4(i,1), obj1(i,1)];
end

end

