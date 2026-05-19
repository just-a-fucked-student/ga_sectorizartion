function [MobjV, obj1, obj2, obj3, obj4] = MultiobjFun(phenotypes, airspace)
% Número de configuracions (individus)
nPhenos = size(phenotypes,1);

% Preparar variables per a resultats
MobjV = zeros(nPhenos, 2);
obj1 = zeros(nPhenos, 1);
obj2 = zeros(nPhenos, 1);
obj3 = zeros(nPhenos, 1);
obj4 = zeros(nPhenos, 1);

for i = 1:nPhenos
    % Convertir configuració a punts Voronoi
    vorxy = phenotype2vor(phenotypes(i,:));
    vor = [vorxy; airspace.vorBounds];

    % Calcular complexitat de sectors
    comp = complexityFunction(vor, airspace);

    % MÈTRIQUES EN RSD (Fonamental per a gamultiobj!)
    obj1(i,1) = std(comp.aircraftInSector) / (mean(comp.aircraftInSector) + 1e-6);
    obj2(i,1) = std(comp.firTransfers) / (mean(comp.firTransfers) + 1e-6);
    obj3(i,1) = std(comp.sectorTransfers) / (mean(comp.sectorTransfers) + 1e-6);
    obj4(i,1) = std(comp.airwaysIntersections) / (mean(comp.airwaysIntersections) + 1e-6);

    % Definim els dos objectius: [Conflictes (obj4), Avions (obj1)]
    MobjV(i,:) = [obj4(i,1), obj1(i,1)];
end
end