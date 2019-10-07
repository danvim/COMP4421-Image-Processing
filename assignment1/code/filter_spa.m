function img_result = filter_spa(img_input, filter)

[height, width] = size(img_input);
[fil_h, fil_w] = size(filter);

padded_image = padarray(img_input, [floor((fil_h-1)/2) floor((fil_w-1)/2)], 0, 'both');
img_result = zeros(height, width);

length = height * width;

for i = 0:length-1
    y = uint32(floor(i / width) + 1);
    x = uint32(mod(i, width) + 1);
    sub_matrix = padded_image(y:y+2, x:x+2);
    weighted = double(sub_matrix) .* double(filter);
    img_result(y,x) = sum(weighted(:));
end

img_result = uint8(abs(img_result));