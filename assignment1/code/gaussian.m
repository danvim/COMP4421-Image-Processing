function f = gaussian(sze, cutoff)

if length(sze) == 1
	M = sze; N = sze;
else
	M = sze(1); N = sze(2);
end

if(mod(M,2) == 0)
    cM = floor(M/2) + 0.5;
else
    cM = floor(M/2) + 1;
end
if(mod(N,2) == 0)
    cN = floor(N/2) + 0.5;
else
    cN = floor(N/2) + 1;
end
%  
% f = zeros(M,N);
% for i = 1:M
%    for j = 1:N
%        dis = (i - cM)^2 + (j - cN)^2;
%         f(i,j) = exp(-dis/2/cutoff^2);
%    end;
% end;
a = [1:M];
b = [1:N];
A = repmat(a',1,N);
B = repmat(b,M,1);
A = (A-cM).^2;
B = (B-cN).^2;
f = exp(-(A+B)./(2*cutoff^2));
f = ones(sze) - f;