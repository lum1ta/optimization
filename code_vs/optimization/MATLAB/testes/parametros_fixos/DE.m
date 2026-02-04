
%% ===================== CONFIGURAÇÃO =====================
dimensions = input('Dimensions: ');
[objetive_function, name_function] = select_function();

size_pop = 100;
generation = 30;
crossover_rate = 0.5;
mutation_factor = 0.4;
limits = [-100, 100];

%% ===================== POPULAÇÃO INICIAL =====================
initial_population = limits(1) + (limits(2) - limits(1)) * rand(size_pop, dimensions);

valor = zeros(size_pop,1);
for i = 1:size_pop
    valor(i) = objetive_function(initial_population(i,:));
end

best_position = zeros(generation, dimensions);
best_fitness_history = zeros(generation,1);

% Remove espaços do nome da função (evita problema em nome de arquivo)
name_clean = strrep(name_function, ' ', '_');

% Define pasta de saída
if isempty(mfilename)
    pasta_saida = pwd;  % se rodar por partes
else
    pasta_saida = fileparts(mfilename('fullpath')); % mesma pasta do script
end

% Nome do arquivo depende da função
arquivo_saida = fullfile(pasta_saida, ['DE_resultados_', name_clean, '.txt']);

fid = fopen(arquivo_saida, 'w');

fprintf('Arquivo sera salvo em:\n%s\n\n', arquivo_saida);

if fid == -1
    error('Falha ao criar arquivo.');
end

fprintf(fid, 'Differential Evolution Results\n');
fprintf(fid, 'Function: %s\n', name_function);
fprintf(fid, 'Dimensions: %d\n\n', dimensions);
fprintf(fid, 'Generation\tBest Fitness\tBest Position\n');


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

    fprintf(fid, '%d\t%.10f\t%s\n', gen, best_fitness, mat2str(best_position(gen,:),4));


    fprintf('Generation %d | Best Fitness = %.6f\n', gen, best_fitness);
end
fclose(fid);


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
    %Zplot = log10(Zplot - Zmin + 1); %escala logaritma


    contourf(X, Y, Zplot, 50, 'LineColor','none', 'DisplayName','Landscape');
    colormap(turbo);
    colorbar;
    caxis([0 log10(Zmax - Zmin + 1)]);
    %colorbar;
    %caxis([Zmin Zmax]);

    plot(best_position(:,1), best_position(:,2), 'w-', 'LineWidth',2, ...
        'DisplayName','Best Path');

    scatter(best_position(:,1), best_position(:,2), 30, 'r','filled', ...
        'DisplayName','Best per Generation');

    scatter(best_solution(1), best_solution(2), 150, 'g','filled', ...
        'MarkerEdgeColor','k','DisplayName','Final Best');

    scatter(initial_population(:,1), initial_population(:,2), 20, 'k','filled', ...
        'MarkerFaceAlpha',0.25,'DisplayName','Final Population');

    title(['Search Landscape - ', name_function])
    xlabel('x_1'); ylabel('x_2');

    legend('Location','bestoutside')
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

    surf(X1, X2, Zplot, 'EdgeColor','none', 'DisplayName','Landscape');
    %set(gca, 'ZScale', 'log') %escala logaritma

    colormap(turbo);
    colorbar;
    caxis([Zmin Zmax]);

    fvals = zeros(size_pop,1);
    for k = 1:size_pop
        fvals(k) = objetive_function(initial_population(k,:));
    end

    scatter3(initial_population(:,1), initial_population(:,2), fvals,...
        25,'k','filled','MarkerFaceAlpha',0.35,'DisplayName','Final Population');

    best_fvals = zeros(generation,1);
    for g = 1:generation
        best_fvals(g) = objetive_function(best_position(g,:));
    end

    plot3(best_position(:,1), best_position(:,2), best_fvals,'w-','LineWidth',2,...
        'DisplayName','Best Path');

    scatter3(best_position(:,1), best_position(:,2), best_fvals,30,'r','filled',...
        'DisplayName','Best per Generation');

    scatter3(best_solution(1), best_solution(2), best_fitness,...
        200,'g','filled','MarkerEdgeColor','k','DisplayName','Final Best');

    title(['Function Surface (x_3 = ', num2str(x3_fixed,3), ') - ', name_function])
    xlabel('x_1'); ylabel('x_2'); zlabel('f(x)');
    view(45,30)

    legend('Location','bestoutside')
end
