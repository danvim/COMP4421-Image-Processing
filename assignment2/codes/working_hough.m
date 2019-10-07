function [img_marked, corners] = hough_transform(img)

% Implement the Hough transform to detect the target A4 paper
% Input parameter:
% .    img - original input image
% .    (You can add other input parameters if you need. If you have added
% .    other input parameters, please state for what reasons in the PDF file)
% Output parameter:
% .    img_marked - image with marked sides and corners detected by Hough transform
% .    corners - the 4 corners of the target A4 paper

% r = x * cos(theta) + y * sin(theta)
% hough_space axis: r(sqrt(w^2*h^2)) by theta(0:90deg)

theta_precision = 10;  % per degree step. 1: 180 theta space
every = 1;  % skip pixels to increase performance. 1: no skipping

% ---

img_bw = rgb2gray(img);
[h, w] = size(img_bw);
theta_space = theta_precision * 180;

% b = medfilt2(img_bw, [20,20]);
open = imopen(img_bw, strel('disk', 5.0));
b = imclose(open, offsetstrel('ball', 50.0, 20));
%b = imbilatfilt(img_bw, 500, 20);  % apply non-linear diffusion
l = fspecial('log', 10, 3);  % define laplacian filter
p = imfilter(b, l);  % apply filter to detect edge
bw = im2bw(p, 0.0001);  % increase strength of edges by thresholding

r_offset = floor(sqrt((w/every)^2+(h/every)^2));
r_max = r_offset*2;  % hough height
hough_space = zeros(r_max, theta_space);

sin_map = zeros(theta_space, 1);
cos_map = zeros(theta_space, 1);

% populate sin and cos maps
radian_step = pi / theta_space;
for i = 0:theta_space-1
    sin_map(i+1) = sin(radian_step * i);
    cos_map(i+1) = cos(radian_step * i);
end

% @ some (x, y) {
%   loop through sin_map {
%     register r
%   }
% } => O(w*h*precision)

small_bw = imresize(bw, 1/every);
[edge_y, edge_x] = find(small_bw);

for i = 1:size(edge_y)
    for theta_step = 0:theta_space-1
        x_ = edge_x(i);
        y_ = edge_y(i);
        x = (edge_x(i)-1)*every+1;
        y = (edge_y(i)-1)*every+1;
        r = x_ * cos_map(theta_step+1) + y_ * sin_map(theta_step+1);
        %r_left = max(floor(r), 0);
        %r_right = min(ceil(r), r_max-1);
        %delta = r - r_left;
        hough_space(floor(r)+r_offset, theta_step+1) = hough_space(floor(r)+r_offset, theta_step+1) + bw(y,x);
        %hough_space(r_left+r_offset, theta_step+1) = hough_space(r_left+r_offset, theta_step+1) + double(bw(y,x))*(1-delta);
        %hough_space(r_right+r_offset, theta_step+1) = hough_space(r_right+r_offset, theta_step+1) + double(bw(y,x))*(delta);
   end
end

%figure, imshow(imresize(mat2gray(real(log(hough_space+1))), [500, 500])); title('Hough Space');
%smoothed_hough_space = imgaussfilt(hough_space, 10);
ths = hough_space;  % thresholded_hough_space
ths(ths < 1000) = 0.0;  % thresholding
hough_max = imregionalmax(imgaussfilt(ths, 30), 8);  % find local peaks

% y = (x*cos(t) - r)/(-sin(t))

[max_r, max_ti] = find(hough_max);


size_max = size(max_r);

%{
line_x = zeros([size_max(1), 2]);
line_y = zeros([size_max(1), 2]);
%}

img_marked = img;

for i = 1:size(max_r)
    cos_t = cos_map(max_ti(i));
    sin_t = sin_map(max_ti(i));
    
    if sin_t == 0
        continue;
    end
    
    r = max_r(i) - r_offset;
    
    %x = [1, w];
    %y = [floor((r - x0*cos_t)/(sin_t)), floor((r - x1*cos_t)/(sin_t))];
    
    x0 = 1;
    x1 = w;
    y0 = floor((r - x0*cos_t)/(sin_t));
    y1 = floor((r - x1*cos_t)/(sin_t));
    
    if y0 < 1
        y0 = 1;
        x0 = floor((r - y0*sin_t)/(cos_t));
    end
    
    if y0 > h
        y0 = h;
        x0 = floor((r - y0*sin_t)/(cos_t));
    end
    
    if y1 < 1
        y1 = 1;
        x1 = floor((r - y1*sin_t)/(cos_t));
    end
    
    if y1 > h
        y1 = h;
        x1 = floor((r - y1*sin_t)/(cos_t));
    end
    
    if min(x0, x1) < 1 || min(y0, y1) < 1 || x0 == x1 || y0 == y1
        continue;
    end
    
    x = [x0, x1];
    y = [y0, y1];
    n_points = max(abs(diff(x)), abs(diff(y)))+1;
    r_index = round(linspace(y(1), y(2), n_points));
    c_index = round(linspace(x(1), x(2), n_points));
    index = sub2ind(size(img_marked), r_index, c_index);
    img_marked(index) = 0;
    img_marked(index+w*h) = 255;
    img_marked(index+w*h*2) = 0;
    
    %{
    line_x(i,:) = [x0, x1];
    line_y(i,:) = [y0, y1];
    %}
end

%{
line_x( ~any(line_x,2), : ) = [];
line_y( ~any(line_y,2), : ) = [];

% shows image with lines
figure, imagesc(img);
line(line_x', line_y');
%}

%figure, imshow(img_marked);
