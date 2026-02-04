%Parâmetro de mutacao variavel a cada geração

%% =============PARAMETROS=================
dimensions = input("Number of dimensions: ");
[objetive_function,name_function] = select_f4();

crossover_rate =  0.1 + 0.8 * rand();
mutation_factor =  0.4; %0.1 + 0.8 * rand();
size_pop =   100;  %100+ 499 * rand();
generation =   randi([30,500]);
limits = [-100,100];

%% ============INICIO DA POPULACAO============

initial_population = limits(1) + (limits(2) - limits(1)) * rand(size_pop, dimensions);

%Calculo do valor da população inicial

valor  = zeros(size_pop,1);
for i = 1:size_pop
    valor(i) = objetive_function(initial_population(i,:));
end

%Inicializacao do vetoor de melhor posicao e melor valor
best_position = zeros(generation,dimensions);
best_fitness_history = zeros(generation,1);

%Remover os espaços dos nomes da função

name_clean = strrep(name_function, ' ', '_');

%Definir pasta de saida

if isempty(mfilename)
    pasta_saida = pwd;

else
    pasta_saida = fileparts(mfilename('full_path'));
end

%Nome do arquivo de acordo com a funcao

arquivo_saida = fullfile(pasta_saida,['DE_resultados_',name_clean,'.txt']);

fid = fopen(arquivo_saida,'w');

fprintf('Arquivo sera salvo em:\n%s\n\n', arquivo_saida);

if fid == -1
    error('Falha ao criar arquivo.');
end

fprintf(fid, 'Differential Evolution Results\n');
fprintf(fid, 'Function: %s\n', name_function);
fprintf(fid, 'Dimensions: %d\n\n', dimensions);
fprintf(fid, 'Generation\tBest Fitness\tBest Position\n');

%% ============ ALGORITMO DE ==============

for gen = 1:generation
    current_mutation_factor = 0.1 + 0.8 * rand();
    for pop =  1:size_pop

        idxs = randperm(size_pop,3);
        while any(idxs == pop)
            idxs = randperm(size_pop,3);
        end

        a = initial_population(idxs(1),:);
        b = initial_population(idxs(2),:);
        c = initial_population(idxs(3),:);

        mutation = a + current_mutation_factor * (b - c);
        mutation = max(mutation,limits(1));
        mutation = min(mutation,limits(2));

        crosspoints = rand(1,dimensions) < crossover_rate;
        if ~any(crosspoints)
            crosspoints(randi(dimensions)) = true;
        end

        trial = initial_population(pop,:);
        trial(crosspoints) = mutation(crosspoints);

        trial_fitness = objetive_function(trial);
        if trial_fitness < valor(pop)
            initial_population(pop,:) = trial;
            valor(pop) = trial_fitness;
        end
    end
    
    [best_fitness,best_idxs] = min(valor);
    best_position(gen,:) = initial_population(best_idxs,:);
    best_fitness_history(gen) =  best_fitness;

    fprintf(fid, '%d\t%.10f\t%s\n', gen, best_fitness, mat2str(best_position(gen,:),4));
    fprintf('Generation %d | Best Fitness = %.6f\n', gen, best_fitness);

end
fclose(fid);

%%  =============RESULTADO FINAL =====================
[best_fitness,best_idxs] = min(valor);
best_solution = initial_population(best_idxs,:);

fprintf('Best Solution: %s\n', mat2str(best_solution,4));
fprintf('Best Fitness: %.6f\n', best_fitness);
fprintf('Objective Function: %s\n', name_function);

%% ==============POLOTAGEM 2D E 3D=============================

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
    %caxis([0 log10(Zmax - Zmin + 1)]);
    colorbar;
    caxis([Zmin Zmax]);

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
