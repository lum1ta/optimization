%fuctions that will be used in the DE

function [objetive_function, name_function] = select_f6()

    fprintf('========FUNCTION SELECTION========\n');
    fprintf('1 - Quadratic\n');
    fprintf('2 - Rosenbrock\n');
    fprintf('3 - Ackley\n');
    fprintf('4 - Rastrigin\n');

    choice = input('Select the objective function (1-4): ');

    while choice < 1 || choice > 4
        fprintf('Invalid choice. Please select a number between 1 and 4.\n');
        choice = input('Select the objective function (1-4): ');
    end

    switch choice
        case 1
            objetive_function = @quadratic;
            name_function = 'Quadratic';
        case 2
            objetive_function = @rosenbrock;
            name_function = 'Rosenbrock';
        case 3
            objetive_function = @ackley;
            name_function = 'Ackley';
        case 4
            objetive_function = @rastrigin;
            name_function = 'Rastrigin';
    end
end

%================ FUNCTION DEFINITIONS =================%
function y = quadratic(x)
    y = sum(x.^2);
end

function y = rosenbrock(x)
    y = sum(100*(x(2:end) - x(1:end-1).^2).^2 + (1 - x(1:end-1)).^2);
end

function y = ackley(x)
    a = 20;
    b = 0.2;
    c = 2 * pi;
    n = length(x);
    sum1 = sum(x.^2);
    sum2 = sum(cos(c * x));
    y = -a * exp(-b * sqrt(sum1 / n)) - exp(sum2 / n) + a + exp(1);
end

function y = rastrigin(x)
    A = 10;
    n = length(x);
    y = A * n + sum(x.^2 - A * cos(2 * pi * x));
end
