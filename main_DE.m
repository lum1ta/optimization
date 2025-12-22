%Basic DE algorithm

D = input('Enter the number of dimensions: '); %Number of dimensions

[objetive_function, name_function] = select_function();
%Parameters
NP = 100; %Population size
G = 500; %Number of generations
limits = [-200,200];
F = rand(); %Mutation factor
CR = rand(); %Crossover probability

%Initialize population
pop = limits(1) + (limits(2) - limits(1)) * rand(NP,D);

%Evaluate initial population
fitness = zeros(NP,1);
for i = 1:NP
    fitness(i) = objetive_function(pop(i,:));
end
%Mutation, Crossover and Selection
for gen = 1:G
    for i = 1:NP
        %Mutation
        idxs = randperm(NP, 3);
        while any(idxs == i)
            idxs = randperm(NP, 3);
        end
        a = pop(idxs(1),:);
        b = pop(idxs(2),:);
        c = pop(idxs(3),:);
        mutant = a + F * (b - c);
        %Crossover
        cross_points = rand(1,D) < CR;
        if ~any(cross_points)
            cross_points(randi(D)) = true;
        end
        trial = pop(i,:);
        trial(cross_points) = mutant(cross_points);
        %Selection
        trial_fitness = objetive_function(trial);
        if trial_fitness < fitness(i)
            pop(i,:) = trial;
            fitness(i) = trial_fitness;
        end
    end
    %Display best fitness in current generation
    [best_fitness, best_idx] = min(fitness);
    fprintf('Generation %d: Best Fitness = %.4f\n', gen, best_fitness);

    [best_fitness, best_idx] = min(fitness);
    best_positions(gen,:) = pop(best_idx,:);
    best_fitness_values(gen) = best_fitness;
end
% Final results
[best_fitness, best_idx] = min(fitness);
best_solution = pop(best_idx,:);
fprintf('========FINAL RESULTS========\n');
fprintf('Best Solution: %s\n', mat2str(best_solution));
fprintf('Best Fitness: %.4f\n', best_fitness);
fprintf('Objective Function: %s\n', name_function);

% ========== PLOT ==========
if D == 2
    figure;
    [X, Y] = meshgrid(linspace(limits(1), limits(2), 200));
    Z = arrayfun(@(x,y) objetive_function([x,y]), X, Y);
    contourf(X, Y, Z, 30); colorbar; hold on;
    colormap('turbo');

    % Path History
    plot(best_positions(:,1), best_positions(:,2), 'm--o', 'LineWidth', 1.5, ...
        'MarkerFaceColor', 'm', 'DisplayName', 'Best Path');

    % Start and end best positions
    plot(best_positions(1,1), best_positions(1,2), 'gp', 'MarkerSize', 12, ...
        'MarkerFaceColor', 'g', 'DisplayName', 'Start');
    plot(best_solution(1), best_solution(2), 'rp', 'MarkerSize', 14, ...
        'MarkerFaceColor', 'r', 'DisplayName', 'Best Solution');

    % Final population
    plot(pop(:,1), pop(:,2), 'ko', 'MarkerFaceColor', 'w', 'DisplayName', 'Final Population');

    xlabel('x_1'); ylabel('x_2');
    title(sprintf('Differential Evolution - %s', name_function));
    legend('Location', 'bestoutside');
    grid on;
end
