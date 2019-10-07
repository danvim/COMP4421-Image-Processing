function img_result = high_freq_emphasis(img_input, a, b, type)

cutoff = 0.1;
n = 1;

if (strcmp(type, 'butterworth'))
    f = butterworth(size(img_input), 0.1, n);
else
    f = gaussian(size(img_input), 50);
end

E = a + b*f;

img_result = uint8(abs(dft_2d(E .* dft_2d(img_input, 'DFT'), 'IDFT')));