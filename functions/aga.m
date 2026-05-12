function res = aga(goal, ng, np, ne, nm, nn, na, fitfun, LB, UB)
% AGA: A Genetic Algorithm
%   Adapted from MOT's AGA to UPC/MGTA Sectorisation project.
%   https://github.com/OpenLlop/MOT
%
% Syntax:
%   res = aga(goal, ng, np, ne, nm, nn, na, fitfun, n, bounds)
%
% Description:
%   This function runs a genetic algorithm (AGA) to find an optimal set of
%   Voronoi sectors based on a specified fitness function. 
%
% Inputs:
%   goal   - Target fitness value to achieve.
%   ng     - Maximum number of generations to run the algorithm.
%   np     - Total population size.
%   ne     - Number of elites to carry over to the next generation.
%   nm     - Number of mutants to introduce in each generation.
%   nn     - Number of newcomers to introduce in each generation.
%   na     - Number of parents used in breeding.
%   fitfun - Fitness function handle.
%   LB     - Lower boundaries of the search space.
%   UB     - Upper boundaries of the search space.
%
% Outputs:
%   res    - Results structure containing:
%            - bestind: Best individual found.
%            - bestfit: Fitness of the best individual.
%            - lastite: Index of the last iteration completed.
%
% See also:
%   ranfun, repfun, mutfun, unifun, prifun

    % Create results struct
    res.bestind = []; % Best individual
    res.bestfit = []; % Best individual's fitness
    res.lastite = []; % Last iteration index

    % Build population
    pop = cell(1,np); % Preallocate population variable
    for i=1:np % Fill population
        pop{i} = ranfun(LB, UB); % Generate random individual
    end

    % Number of descendants
    % >> elites + mutants + newcomers --> the rest are descendants
    nd = np - ne - nm - nn;

    % Safety-check: ensure consistent population
    if nd < 0
        fprintf("ERROR: NUMBER OF DESCENDANTS IS NEGATIVE!\n");
        fprintf("ADJUST PERCENTAGE OF MUTANTS AND NEWCOMERS.\n");
        fprintf("AGA inconsistent population; leaving.\n");
        return;
    end

    % Iterate through generations
    for g=1:ng

        % Preallocate/clear fitness array
        fi = zeros(np,1); 

        % Clean-up population: remove repeated individuals
        [pop,fi] = unifun(pop,fi); % Return unique individuals
        idx = cellfun('isempty',pop); % Empty individuals indexes
        pop = pop(~idx); % Remove empty individuals
        fi = fi(~idx); % Remove empty fitness
        ncleanpop = length(pop); % Size of clean population

        % Avoid population degeneration (i.e., poor genetic pool)
        if ncleanpop<na % Population size is less than breeders size
            res.bestind = pop{1}; % Save best individual
            res.bestfit = fi(1); % Save fitness of best individual
            res.lastite = g; % Save current generation index
            fprintf('AGA degenerate population; leaving.\n');
            break; % Stop iterating
        end

        % Repopulation: fill population pool with new individuals
        for i=ncleanpop+1:np % Fill up to initial population size
            pop{i} = ranfun(LB, UB); % Create new random individual
        end

        % Evaluate fitness function
        for i=1:np
            fi(i) = fitfun(pop{i});
        end

        % Sort population individuals by their fitness level
        [fi,i] = sort(fi); % Sort (lower is best)
        pop = pop(i); % Sort population by fitness

        % Check: target fitness | max generations
        if fi(1)<=goal || g>=ng
            res.bestind = pop{1}; % Save best individual
            res.bestfit = fi(1); % Save best fitness level
            res.lastite = g; % Save current generation index
            fprintf('AGA nite=%2d fitbest=%f',g,res.bestfit);
            fprintf(' best='); prifun(res.bestind);
            if res.bestfit<goal % Goal achieved
                fprintf(' goal=%e achieved; leaving\n',goal);
            elseif g>=ng % Maximum generations reached
                fprintf(' max. iterations reached; leaving\n');
            end
            break; % Stop iterating
        end

        % Show current generation info
        fprintf('AGA g=%2d fitbest=%f',g,fi(1));
        fprintf(' best='); prifun(pop{1});
        fprintf('\n');

        % Compute population for next generation:
        % <<[elites, mutants, descendants, newcomers]<<
        nextpop = cell(1,ne+nm+nn+nd); % Preallocate next population
        k = 1; % Start individual counter index

        for i=1:ne % Elites (from ne best individuals)
            nextpop{k} = pop{k}; % Copy elite into next generation
            k = k + 1; % Next individual
        end

        for i=1:nm % Mutants (from nm best individuals)
            nextpop{k} = mutfun(pop{i}, LB, UB); % Mutate
            k = k + 1; % Next individual
        end

        for i=1:nd % Descendants (from na best individuals)
            parentA = randi([1,na]); % Parent A is chosen among the na best 
            parentB = randi([1,na]); % Parent B is chosen among the na best 
            nextpop{k} = repfun(pop{parentA}, pop{parentB}, ...
                fi(parentA), fi(parentB)); % Breed individuals A and B
            k = k + 1; % Next individual
        end

        for i=1:nn % Newcomers
            nextpop{k} = ranfun(LB, UB); % Random individual
            k = k + 1; % Next individual
        end

        % Update population
        pop = nextpop;

    end

end

% Mutation function
function y = mutfun(x, LB, UB)
    dphenotype = (UB - LB) / 10; % Random perturbation
    y = x + dphenotype; % Mutate individual
    y = sortCoordsByLon(y); % Sort points by longitude
end

% Reproduction function
function y = repfun(x, y, ~, ~)
    y = (x + y) / 2;
    y = sortCoordsByLon(y); % Sort points by longitude
end

% Random function
function y = ranfun(LB, UB)

    % Generate random values between LB and UB
    y = LB + (UB - LB) .* rand(1, length(LB));
    y = sortCoordsByLon(y); % Sort points by longitude

end

% Unique function
function [pop, fi] = unifun(x, f)
    [pop, fi] = deal(x, f);
end

% Print function
function y = prifun(x)
    y = fprintf('%.2f ', x);
end
