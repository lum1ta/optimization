% rascunho: testes rápidos

global fun phi Matriz_Q

n = 5;
x0 = zeros(n,1);
R = 5;
niter = 1000;
maxneval = 1e5;
Npop = 50;
funct = 'fobj';
param = [0.75 0.75]; % F, Cr

% --------------------
lb = -100;
ub = 100;
Box = repmat([lb ub], n, 1);

fun = 13;
phi = 1e-8;
Q0 = randn(n,n);
Q0 = eye(n);
Matriz_Q = Q0'*Q0;
% --------------------

if fun==1
    titulo = ['Quadrática,  phi = ',num2str(phi),',   n = ',int2str(n)];
elseif fun==13
    titulo = ['Rosenbrock,    n = ',int2str(n)];
elseif fun==16
    titulo = ['Rastrigin rotacionada,     n = ',int2str(n)];
elseif fun==17
    titulo = ['Ackley rotacionada,     n = ',int2str(n)];
elseif fun==18
    titulo = ['Schwefel,     n = ',int2str(n)];
end


% Basic DE:
[Fopbas,Xopbas,Nevbas,Hfbas,Hxbas,Hnevbas] = DEbas(funct,Npop,niter,x0,R,param);

figure
semilogy(Hnevbas,Hfbas)
title(titulo)




