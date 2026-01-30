
%% ===================== CONFIGURAÇÃO =====================
dimensions = input('Dimensions: ');
[objetive_function, name_function] = select_function();

size_pop = 100;
generation = 30;
crossover_rate = 0.5;
mutation_factor = 0.4;
limits = [-10000, 10000];

%% ===================== POPULAÇÃO INICIAL =====================
initial_population = limits(1) + (limits(2) - limits(1)) * rand(size_pop, dimensions);

valor = zeros(size_pop,1);
for i = 1:size_pop
    valor(i) = objetive_function(initial_population(i,:));
end

best_position = zeros(generation, dimensions);
best_fitness_history = zeros(generation,1);

%% ===================== DIFFERENTIAL EVOLUTION =====================
for gen = 1:generation
    for pop = 1:size_pop

        idxs = randperm(size_pop,3);
        while any(idxs == pop)
            idxs = randperm(size_pop,3);
        end

        a = initial_population(idxs(1),:);
        b = initial_population(idxs(2),:);
        c = initial_population(idxs(3),:);

        mutant = a + mutation_factor * (b - c);
        mutant = max(mutant, limits(1));
        mutant = min(mutant, limits(2));

        cross_points = rand(1,dimensions) < crossover_rate;
        if ~any(cross_points)
            cross_points(randi(dimensions)) = true;
        end

        trial = initial_population(pop,:);
        trial(cross_points) = mutant(cross_points);

        trial_fitness = objetive_function(trial);
        if trial_fitness < valor(pop)
            initial_population(pop,:) = trial;
            valor(pop) = trial_fitness;
        end
    end

    [best_fitness, best_idx] = min(valor);
    best_position(gen,:) = initial_population(best_idx,:);
    best_fitness_history(gen) = best_fitness;

    fprintf('Generation %d | Best Fitness = %.6f\n', gen, best_fitness);
end

%% ===================== RESULTADO FINAL =====================
fprintf('\n======== FINAL RESULTS ========\n');
[best_fitness, best_idx] = min(valor);
best_solution = initial_population(best_idx,:);

fprintf('Best Solution: %s\n', mat2str(best_solution,4));
fprintf('Best Fitness: %.6f\n', best_fitness);
fprintf('Objective Function: %s\n', name_function);

%%% ===================== FUNCTION LANDSCAPE PLOT =====================

if dimensions == 2
    figure; hold on; grid on;

    [X, Y] = meshgrid(linspace(limits(1), limits(2), 300));
    Z = arrayfun(@(x,y) objetive_function([x,y]), X, Y);

    Zmin = min(best_fitness_history);
    Zmax = prctile(Z(:), 90);
    Zplot = min(Z, Zmax);

    hLandscape = contourf(X, Y, Zplot, 50, 'LineColor','none');
    colormap(turbo);
    colorbar;
    caxis([Zmin Zmax]);

    hPath = plot(best_position(:,1), best_position(:,2), 'w-', 'LineWidth',2);
    hBestGen = scatter(best_position(:,1), best_position(:,2), 30, 'r','filled');
    hBestFinal = scatter(best_solution(1), best_solution(2), 150, 'g','filled','MarkerEdgeColor','k');
    hPop = scatter(initial_population(:,1), initial_population(:,2), 20, 'k','filled','MarkerFaceAlpha',0.25);

    title(['Search Landscape - ', name_function])
    xlabel('x_1'); ylabel('x_2');

    legend([hLandscape(1) hPath hBestGen hBestFinal hPop], ...
        {'Landscape','Best Path','Best per Generation','Final Best','Final Population'}, ...
        'Location','bestoutside');
end

if dimensions == 3
    figure; hold on; grid on;

    x3_fixed = best_solution(3);
    [X1, X2] = meshgrid(linspace(limits(1), limits(2), 150));
    Z = zeros(size(X1));

    for i = 1:size(X1,1)
        for j = 1:size(X1,2)
            Z(i,j) = objetive_function([X1(i,j), X2(i,j), x3_fixed]);
        end
    end

    Zmin = min(best_fitness_history);
    Zmax = prctile(Z(:), 90);
    Zplot = min(Z, Zmax);

    hSurf = surf(X1, X2, Zplot, 'EdgeColor','none');
    colormap(turbo);
    colorbar;
    caxis([Zmin Zmax]);

    fvals = zeros(size_pop,1);
    for k = 1:size_pop
        fvals(k) = objetive_function(initial_population(k,:));
    end
    hPop3 = scatter3(initial_population(:,1), initial_population(:,2), fvals,...
        25,'k','filled','MarkerFaceAlpha',0.35);

    best_fvals = zeros(generation,1);
    for g = 1:generation
        best_fvals(g) = objetive_function(best_position(g,:));
    end
    hPath3 = plot3(best_position(:,1), best_position(:,2), best_fvals,'w-','LineWidth',2);
    hBestGen3 = scatter3(best_position(:,1), best_position(:,2), best_fvals,30,'r','filled');
    hBestFinal3 = scatter3(best_solution(1), best_solution(2), best_fitness,...
        200,'g','filled','MarkerEdgeColor','k');

    title(['Function Surface (x_3 = ', num2str(x3_fixed,3), ') - ', name_function])
    xlabel('x_1'); ylabel('x_2'); zlabel('f(x)');
    view(45,30)

    legend([hSurf hPath3 hBestGen3 hBestFinal3 hPop3], ...
        {'Landscape','Best Path','Best per Generation','Final Best','Final Population'}, ...
        'Location','bestoutside');
end
