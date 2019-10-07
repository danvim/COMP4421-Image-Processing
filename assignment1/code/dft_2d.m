function img_result = dft_2d(img_input, flag)

% You should include the center shifting in this function

[m, n] = size(img_input);

sign = -1;

if strcmp(flag, 'IDFT')
    sign = 1;
end

c = sign * 1j * 2 * pi;

% F = h * (f * W_N)

W_M = complex(zeros(m,m), 0);
W_N = complex(zeros(n,n), 0);

for y = 1:m
    W_M(y,:) = exp(c * y * (0:m-1) / m);
end

for x = 1:n
    W_N(:,x) = exp(c * x * (0:n-1) / n);
end

img_result = (W_N * double(img_input)' * W_M)';

if strcmp(flag, 'DFT')
    % img_result = log(img_result);
    img_result = circshift(img_result, [floor(m/2) floor(n/2)]);
else
    img_result = 1/(m*n) * img_result;
    img_result = uint8(abs(img_result));
end


