function A = crossover(Cr,n,type)
%
% A    -> n-vector indicating coordinates to be exchanged
% Cr   -> crossover rate
% type -> 'bin' or 'exp'
%

nargs = nargin;
if nargs == 2
    type = 'bin';
end
if Cr < 0
    Cr = 0;
elseif Cr > 1
    Cr = 1;
end

if type=='bin'
    A = (rand(n,1) < Cr);
    if sum(A)==0
        A(floor(rand(1)*n+1))=1;
    end
elseif type=='exp'
    A = zeros(1,n);
    J = floor(n*rand(1))+1;
    T = Cr.^[0:n-1];
    R = rand(1,n);
    Tr = [(T > R) 0];
    k = find(Tr==0,1)-1;
    if J + k <= n
        A(J:J+k-1) = ones(1,k);
    else
        A(1,J:n) = 1;
        A(1,1:k-n+J-1) = 1;
    end
    A = A';
end

        
    