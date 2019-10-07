function img_warp = img_warping(img, corners, n)

% Implement the image warping to transform the target A4 paper into the
% standard A4-size paper
% Input parameter:
% .    img - original input image
% .    corners - the 4 corners of the target A4 paper detected by the Hough transform
% .    (You can add other input parameters if you need. If you have added
% .    other input parameters, please state for what reasons in the PDF file)
% Output parameter:
% .    img_warp - the standard A4-size target paper obtained by image warping
% .    n - determine the size of the result image

% compare distance: short -> short edge, medium -> long edge, long -> opposite
%
% A--S
% |  |
% |  |
% L--O
%

a_ = corners(1,:);  % current
s_ = corners(2,:);  % short
l_ = corners(3,:);  % long
o_ = corners(4,:);  % opposite

%% Allocate 4 corners

as = norm(s_-a_);
al = norm(l_-a_);
ao = norm(o_-a_);

if as < al && al < ao
    %fine
    disp('Case a');
elseif as < ao && ao < al
    %swap o and l
    o_ = corners(3,:);
    l_ = corners(4,:);
    disp('Case b');
elseif ao < as && as < al
    s_ = corners(4,:);
    l_ = corners(2,:);
    o_ = corners(3,:);
    disp('Case c');
elseif ao < al && al < as
    s_ = corners(4,:);
    o_ = corners(2,:);
    disp('Case d');
elseif al < ao && ao < as
    s_ = corners(3,:);
    l_ = corners(4,:);
    o_ = corners(2,:);
    disp('Case e');
elseif al < as && as < ao
    s_ = corners(3,:);
    l_ = corners(2,:);
    disp('Case f');
end

%% Check for reflection
a_s = a_-s_;
o_s = o_-s_;
u = [a_s(1), a_s(2), 0];
v = [o_s(1), o_s(2), 0];

% negative cross sum means flipped
calc_angle = atan2d(u(2)*v(1)-u(1)*v(2),u(2)*v(2)+u(1)*v(1));

if calc_angle > 0
    % flipped
    tmp = a_;
    a_ = s_;
    s_ = tmp;
    tmp = l_;
    l_ = o_;
    o_ = tmp;
    
    disp('Page was mirrored. Now fixed...');
end

%{

img_marked_2 = img;
img_marked_2(a_(1), a_(2),:) = [255 0 0];
img_marked_2(s(1), s(2),:) = [0 255 0];
img_marked_2(l(1), l(2),:) = [0 0 255];
img_marked_2(o(1), o(2),:) = [0 0 0];
figure, imshow(img_marked_2);

%}

%% Begin Projective

% Assuming we are transforming the correct coordinates into the unfixed
% ones.

A = [1 1];
S = [1 210*n+1];
L = [297*n+1 1];
O = [297*n+1 210*n+1];

Alpha = [
    a_(2)	a_(1)   1       0       0       0   -a_(2)*A(2) -a_(1)*A(2);
    s_(2)   s_(1)   1       0       0       0   -s_(2)*S(2) -s_(1)*S(2);
    l_(2)   l_(1)   1       0       0       0   -l_(2)*L(2) -l_(1)*L(2);
    o_(2)   o_(1)   1       0       0       0   -o_(2)*O(2) -o_(1)*O(2);
    0       0       0       a_(2)	a_(1)   1   -a_(2)*A(1) -a_(1)*A(1);
    0       0       0       s_(2)   s_(1)   1   -s_(2)*S(1) -s_(1)*S(1);
    0       0       0       l_(2)   l_(1)   1   -l_(2)*L(1) -l_(1)*L(1);
    0       0       0       o_(2)   o_(1)   1   -o_(2)*O(1) -o_(1)*O(1);
    ];

Beta = [A(2);S(2);L(2);O(2);A(1);S(1);L(1);O(1)];

X = linsolve(Alpha, Beta);

disp('Done solving perspective matrix...');

% Construct transformation matrix

perspective = [
    X(1)    X(2)    X(3);
    X(4)    X(5)    X(6);
    X(7)    X(8)    1;
    ];

target_height = O(1);
target_width = O(2);

img_warp = uint8(zeros([target_height-1, target_width, 3]));
img_tmp = zeros(size(img));

[source_height, source_width, ~] = size(img);

for y = 1:target_height
    for x = 1:target_width
        loc = inv(perspective)*[x;y;1];
        loc(1) = loc(1)/loc(3);
        loc(2) = loc(2)/loc(3);
        
        if (loc(2) > 0 && loc(2) <= source_height && loc(1) > 0 && loc(1) <= source_width)

            x1 = floor(loc(1));
            x2 = ceil(loc(1));
            y1 = floor(loc(2));
            y2 = ceil(loc(2));

            x1y1 = double(img(y1, x1,:));
            x1y2 = double(img(y2, x1,:));
            x2y1 = double(img(y1, x2,:));
            x2y2 = double(img(y2, x2,:));

            xd = 1-(loc(1) - x1);
            yd = 1-(loc(2) - y1);

            top_avg = x1y1*xd + x2y1*(1-xd);
            bottom_avg = x1y2*xd + x2y2*(1-xd);

            vertical_avg = top_avg*yd + bottom_avg*(1-yd);

            img_warp(y, x, :) = uint8(vertical_avg);
        
        end
    end
end

disp('Done warping...');
