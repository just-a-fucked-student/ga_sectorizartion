%% Codi de la part del estudi de convergencia, el guardem aqui per no perdre'l i fer neteja al main
fprintf('Iniciant l''estudi de convergència Monte Carlo...\n');

M_iter = 200;
fitxer_mc = 'data/mc_checkpoint.txt';
costos_MC = zeros(M_iter, 1);
k_inici = 0;

% 1. Sistema de guardat (Checkpoint)
if exist(fitxer_mc, 'file') == 2
    fprintf('S''ha trobat un fitxer de guardat previ. Llegint dades...\n');
    dades_previes = load(fitxer_mc);
    k_inici = length(dades_previes);

    if k_inici > 0
        % Carregar les dades ja calculades
        costos_MC(1:k_inici) = dades_previes(1:min(k_inici, M_iter));
        fprintf('S''han recuperat %d iteracions.\n', k_inici);
    end
end

% 2. Paràmetres fixes per a l'estudi de convergència
np = 30; % Population Size de prova
ng = 30; % Max Generations de prova
ne = 2; % Número d'elits
nm = round(np * 0.3); % Mutants
nn = round(np * 0.1); % Nous
na = round(np * 0.4); % Pares (Crossover)

% 3. Obrir el fitxer per escriure al final de l'arxiu
fid = fopen(fitxer_mc, 'a');

for k = (k_inici + 1):M_iter
    fprintf('\n--- Executant iteració MC %d de %d ---\n', k, M_iter);

    % Executem l'AGA
    res_MC = aga(0.0, ng, np, ne, nm, nn, na, objFun1D, LB, UB);

    % Guardem el millor cost d'aquesta iteració
    costos_MC(k) = res_MC.bestfit;

    % Escriure el valor al fitxer de text al moment per si peta
    fprintf(fid, '%f\n', costos_MC(k));
end

fclose(fid);
fprintf('Monte Carlo finalitzat!\n');


% Calcular la mitjana i la desviació estàndard acumulada
avg_cost = zeros(M_iter, 1);
std_cost = zeros(M_iter, 1);

for k = 1:M_iter
    avg_cost(k) = mean(costos_MC(1:k));

    if k > 1
        std_cost(k) = std(costos_MC(1:k));
    else
        std_cost(k) = 0; 
    end
end

% Dibuixar la gràfica amb doble eix Y
figure('Name', 'Monte Carlo Convergence');
yyaxis left
plot(1:M_iter, avg_cost, 'b-', 'LineWidth', 1.5);
ylabel('average cost');
ylim([min(avg_cost(2:end))*0.9, max(avg_cost)*1.1]);

yyaxis right
plot(1:M_iter, std_cost, 'r--', 'LineWidth', 1.5);
ylabel('std of average cost');
ylim([0, max(std_cost)*1.2]);

xlabel('monte-carlo iterations [#]');
title('Convergència del Monte Carlo');
legend('average cost', 'std of average cost', 'Location', 'northeast');
grid on;