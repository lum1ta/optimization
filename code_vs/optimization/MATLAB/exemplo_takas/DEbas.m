function [Fop,Xop,Nev,Hf,Hx,Hnev] = DEbas(funct,Npop,niter,x0,R,param)
% 
% Differential Evolution
%
% Basic algorithm
%

% Outputs:
% Fop - best objective function value
% Xop - best decision vector
% Nev - number of function evaluations (total)
% Hf - archive of best objective function on each iteration
% Hx - archive of the best decision vectors
% Hnev - number of acumulated function evaluations up to each iteration

% Inputs:
% funct - string with the name of the objective function
% Npop - number of individuals in population
% niter - number of iterations to be executed
% x0 - center of initial population (multivariate Gaussian distribution) 
% R - radius (standard deviation) of initial population
% param: DE parameters (optional)
% param(1) - F 
% param(2) - Cr


N = Npop;

type = 'bin';
if nargin < 6
    F = 0.75;
    Cr = 0.5;
else
    F = param(1);
    Cr = param(2);
end

fX = zeros(1,N);
fX2 = fX;
neval = 0;
n = size(x0,1);
Hf = zeros(niter,1);
Hx = zeros(niter,n);
Hnev = zeros(niter,1);

XX = R*randn(n,N)/sqrt(n) + x0*ones(1,N);
h = 1;
XX2 = XX;
for j=1:N
    fX(j) = feval(funct,XX(:,j));
end
neval = neval + N;
[fop,jop] = min(fX);
xop = XX(:,jop);
Hf(h) = fop;
Hx(h,:) = xop';
Hnev(h) = neval;
while h < niter
    for i=1:N
        i1 = i;
        V = [1:N];
        V(i) = [];
        ind = randperm(N-1,3);
        i2 = V(ind(1));
        i3 = V(ind(2));
        i4 = V(ind(3));
        x1 = XX(:,i1);
        x2 = XX(:,i2);
        x3 = XX(:,i3);
        x4 = XX(:,i4);
        A = crossover(Cr,n,type);
        nA = 1-A;
        o = nA.*x1 + A.*(x2 + F*(x3-x4));
        fo = feval(funct,o);
        neval = neval+1;
        fx1 = fX(i);
        if fo < fx1
            xi = o;
            fX2(i) = fo;
        else
            xi = x1;
            fX2(i) = fx1;
        end
        XX2(:,i) = xi;
        if fo < fop
            xop = o;
            fop = fo;
        end
    end
    XX = XX2;
    fX = fX2;
    h = h+1;
    Hf(h) = fop;
    Hx(h,:) = xop';
    Hnev(h) = neval;
end

Fop = fop;
Xop = xop;
Nev = neval;





