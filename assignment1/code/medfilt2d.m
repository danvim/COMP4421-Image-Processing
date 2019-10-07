function img_result = medfilt2d(img_input, s)

[height, width] = size(img_input);

padded_image = padarray(img_input, [(s-1)/2 (s-1)/2], 'replicate', 'both');
img_result = zeros(height, width);

for y = 1:height
    for x = 1:width
        % convolve
        sub_matrix = padded_image(y:y+s-1, x:x+s-1);
        img_result(y,x) = median(sub_matrix(:));
    end
end

img_result = mat2gray(img_result);