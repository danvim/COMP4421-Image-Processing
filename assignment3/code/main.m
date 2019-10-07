clc
clear

% Before this script is carried out, I have trained 3 models using the
% other scripts in this folder, and the outputs are saved as .mat files.

img_name = '../input images/3.bmp';
img = imread(img_name);

[digits_set] = digit_segment(img);

accuracy = ada_classification(digits_set);
