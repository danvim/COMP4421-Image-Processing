function img_result = filter2d_fre(img_input, filter)

[h, w] = size(img_input);
[fil_h, fil_w] = size(filter);
img_padded = zeros(2*h, 2*w);
img_padded(1:h, 1:w) = img_input;
filter_padded = zeros(2*h, 2*w);
filter_padded(1:fil_h, 1:fil_w) = filter;

dft_img = dft_2d(img_padded, 'DFT');
dft_filter = dft_2d(filter_padded, 'DFT');

img_result = dft_2d(dft_img .* dft_filter, 'IDFT');
img_result = img_result(1:h, 1:w);