%Codi HTP per guardar-lo i netejar el main per poder fer Run 
%% SECTION 8: HYPER-PARAMETER TUNING (WP2)
fprintf('Iniciant Hyper-Parameter Tuning...\n');

% Llistes de paràmetres a provar (modifica-ho segons el que vulguis esperar)
PS_list = [10, 20, 30];       % Provarem 3 mides de població
MaxGen_list = [10, 20, 30];   % Provarem 3 màxims de generacions
MC_hpt = 150;                 % El teu N ideal estabilitzat

% Matriu per guardar les mitjanes dels resultats finals
mean_fitness_matrix = zeros(length(MaxGen_list), length(PS_list));

% Calcular el total d'execucions per tenir una idea del temps
total_runs = length(PS_list) * length(MaxGen_list) * MC_hpt;
fprintf('Atenció: Es faran un total de %d execucions de l''AGA.\n', total_runs);
run_counter = 0;

for i = 1:length(MaxGen_list)
    ng = MaxGen_list(i);

    for j = 1:length(PS_list)
        np = PS_list(j);

        % Recalcular paràmetres derivats per a l'AGA segons aquesta Població (np)
        ne = 2; % Elits
        nm = round(np * 0.3); % Mutants (30% per defecte, comprova els teus apunts)
        nn = round(np * 0.1); % Nous (10%)
        na = round(np * 0.4); % Pares (40%)

        fprintf('\nTestejant PS = %d | MaxGen = %d...\n', np, ng);

        costos_actuals = zeros(MC_hpt, 1);

        % Bucle Monte Carlo per a aquesta combinació
        for k = 1:MC_hpt
            % Executar AGA
            res = aga(0.0, ng, np, ne, nm, nn, na, objFun1D, LB, UB);
            costos_actuals(k) = res.bestfit;

            run_counter = run_counter + 1;
            if mod(run_counter, 100) == 0
                fprintf('  ... %d/%d execucions completades\n', run_counter, total_runs);
            end
        end

        % Guardar la mitjana d'aquesta casella a la matriu
        mean_fitness_matrix(i, j) = mean(costos_actuals);
    end
end

% Guardar els resultats en un arxiu .mat
save('data/hpt_results.mat', 'mean_fitness_matrix', 'PS_list', 'MaxGen_list');
fprintf('Hyper-Parameter Tuning finalitzat!\n');

%% SECTION 9: POST-PROCESSING HPT (Heatmap)
figure('Name', 'HPT - Mean Fitness');

% Dibuixar el Heatmap
imagesc(PS_list, MaxGen_list, mean_fitness_matrix);
colorbar;
colormap('parula'); % Escala de colors similar a la de les slides
xlabel('Population');
ylabel('Generations');
title('Mean Fitness Value');

% Posar els eixos en ordre ascendent (de baix cap a dalt)
set(gca, 'YDir', 'normal'); 

% Mostrar la configuració òptima guanyadora per consola
[min_val, min_idx] = min(mean_fitness_matrix(:));
[row_min, col_min] = ind2sub(size(mean_fitness_matrix), min_idx);
fprintf('\n>> LA MILLOR CONFIGURACIÓ ÉS:\n');
fprintf('Population (PS) = %d\n', PS_list(col_min));
fprintf('Max Generations = %d\n', MaxGen_list(row_min));
fprintf('Amb un cost mitjà de: %.4f\n', min_val);


%Resultats HPT:
%LA MILLOR CONFIGURACIÓ ÉS:
%Population (PS) = 30
%Max Generations = 30
%Cost mitjà de: 0.1906