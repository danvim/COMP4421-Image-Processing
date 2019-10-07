clc
clear

img = imread('88.png');

%% --------------- Task 1: Spatial Linear Filtering --------------- 
averaging_mask = 1/9*ones(3,3);
sobelX_mask = [1 0 -1; 2 0 -2; 1 0 -1];
sobelY_mask = [1 2 1; 0 0 0; -1 -2 -1];
laplacian_mask = [0 1 0; 1 -4 1; 0 1 0];

ave_result = filter_spa(img, averaging_mask);
sobelX_result = filter_spa(img, sobelX_mask);
sobelY_result = filter_spa(img, sobelY_mask);
laplacian_result = filter_spa(img, laplacian_mask) + img;

imwrite(ave_result, '../result images/task1/img_ave.png');
imwrite(sobelX_result, '../result images/task1/img_dx.png');
imwrite(sobelY_result, '../result images/task1/img_dy.png');
imwrite(laplacian_result, '../result images/task1/img_sharpen.png');

subplot(221), imshow(ave_result), title('Averaging')
subplot(222), imshow(sobelX_result), title('Sobel X')
subplot(223), imshow(sobelY_result), title('sobel Y')
subplot(224), imshow(laplacian_result), title('Laplacian')

%%  --------------- Task 2: Spatial Non-linear Filtering  --------------- 

% add gaussian noises to the original input image
img_gau = noiseGenerate(img, 0, 0, 30);

% add salt-and-pepper noises to the original input image
img_sp = noiseGenerate(img, 1, 0.3, 0.3);

size = 3;

gau_result = medfilt2d(img_gau, size);
sp_result = medfilt2d(img_sp, size);

imwrite(img_gau, '../result images/task2/img_gau.png');
imwrite(img_sp, '../result images/task2/img_sp.png');
imwrite(gau_result, '../result images/task2/med_gau.png');
imwrite(sp_result, '../result images/task2/med_sp.png');

figure,
subplot(121), imshow(gau_result), title('Median Filter with Gaussian Noises')
subplot(122), imshow(sp_result), title('Median Filter with Salt-and-Pepper Noises')

%%  --------------- Task 3: Discrete Fourier Transform  --------------- 
dft_img = dft_2d(img, 'DFT');

% Compute the Fourier Spectrum. Remember to do the enhancement.
dft_spectrum = real(log(dft_img));
dft_spectrum = mat2gray(dft_spectrum);
imwrite(dft_spectrum, '../result images/task3/dft_spectrum.png');

idft_img = dft_2d(dft_img, 'IDFT');

% Transform idft_img to a real-value matrix
real_img = uint8(abs(idft_img));

figure,
subplot(121), imshow(dft_spectrum), title('Fourier Spectrum')
subplot(122), imshow(real_img), title('Image after IDFT')

%% ---------- Task 4: Filtering in the Frequency Domain -----------
averaging_mask = 1/25*ones(5,5);
laplacian_mask = [-1 -1 -1; -1 9 -1; -1 -1 -1];

ave_freq = filter2d_fre(img, averaging_mask);
laplacian_freq = filter2d_fre(img, laplacian_mask);

imwrite(ave_freq, '../result images/task4/img_ave_freq.png');
imwrite(laplacian_freq, '../result images/task4/img_sharpen_freq.png');

figure,
subplot(121), imshow(ave_freq), title('Averaging in Frequancy Domain')
subplot(122), imshow(laplacian_freq), title('Sharpen in Frequency Domain')

%% Task 5: High-Frequency Emphasis
a = 0.5;
b = 2;

butter_result = high_freq_emphasis(img, a, b, 'butterworth');
gaussian_result = high_freq_emphasis(img, a, b, 'gaussian');

imwrite(butter_result, '../result images/task5/butter_emphasis_0.5_2.png');
imwrite(gaussian_result, '../result images/task5/gaussian_emphasis_0.5_2.png');

figure,
subplot(121), imshow(butter_result), title('Using Butterworth')
subplot(122), imshow(gaussian_result), title('Using Gaussian')
