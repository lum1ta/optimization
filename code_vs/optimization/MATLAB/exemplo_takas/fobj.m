function y = fobj(x)
global fun phi Matriz_Q

n = length(x);
if fun==1  % function f4ns
    v1 = ones(n,1)/sqrt(n);
    v2 = null(v1');
    V = [v1 v2];
    d = ones(1,n);
    d(1) = phi;
    D = diag(d);
    Q = V'*D*V/phi;
    y = x'*Q*x;
elseif fun==2  % function f4s
    %phi = 10000; 
    Q = eye(n);
    %Q(1,1) = phi;
    y = x'*Q*x;
elseif fun==3   % function f2ns
    d = ones(n,1)/sqrt(n);
    xd = (x'*d)*d;
    xp = x - xd;
    y = xp'*xp;
elseif fun==4  % function f3ns
    d = ones(n,1)/sqrt(n);
    y = (x'*d)^2;
elseif fun==5  % function f1ns
    y = x'*x;
elseif fun==6 % function f3s
    y = x(1)^2;
elseif fun==7  % function f2s
    xp = x;
    xp(1) = 0;
    y = xp'*xp;
elseif fun==8  % two axis (ns) - separated
    v1 = ones(n,1)/sqrt(n);
    v2 = null(v1');
    V = [v1 v2];
    %phi = 1e-4;
    d = ones(1,n);
    d(1) = phi;
    nd = floor(n/2);
    d(nd) = 2*phi;
    D = diag(d);
    Q = V'*D*V/phi;
    y = x'*Q*x;
elseif fun==9  % two axis (ns) - joined
    v1 = ones(n,1)/sqrt(n);
    v2 = null(v1');
    V = [v1 v2];
    %phi = 1e-4;
    d = ones(1,n);
    d(1) = phi;
    d(2) = 2*phi;
    D = diag(d);
    Q = V'*D*V/phi;
    y = x'*Q*x;
elseif fun==10 % two axis (s) - separated
    Q = eye(n);
    Q(1,1) = phi;
    nd = floor(n/2);
    Q(nd,nd) = 2*phi;
    y = x'*Q*x;
elseif fun==11 % several different eigenvalues
    k = [1:n];
    %d = 2.^k;
    d = 1.2.^k;
    Q = diag(d);
    y = x'*Q*x;
elseif fun==12 % non-separable different eigenvalues
    Q = Matriz_Q;
    y = x'*Q*x;
elseif fun==13 % Rosenbrock function
    y = 0;
    for i=1:n-1
        y = y + 100*(x(i+1) - x(i)^2)^2 + (x(i) - 1)^2;
    end
elseif fun==14  % inf norm
    y = max(abs(x));
elseif fun==15  % diagonal rand
    Q = Matriz_Q;
    y = x'*Q*x;
elseif fun==16  % rotated Rastrigin
    Q = Matriz_Q;
    z = Q*x;
    y = 0;
    for i=1:n
        y = y + z(i)^2 - 10*cos(2*pi*z(i)) + 10;
    end
elseif fun==17  % rotated Ackley
    Q = Matriz_Q;
    z = Q*x;
    cz = cos(2*pi*z);
    y = -20*exp(-0.2*sqrt(z'*z/n)) - exp(sum(cz)/n) + 20 + exp(1);
elseif fun==18  % Schwefel
    y = 0;
    for i=1:n
        y = y + (sum(x(1:i)))^2;
    end
end

