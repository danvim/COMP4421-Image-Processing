function [digits_set] = digit_segment(img)

% Implement the digit segmentation
% img: input image
% digits_set: a matrix that stores the segmented digits. The number of rows
%            equal to the number of digits in the iuput image. Each digit 
%            is stored in each row.


%% Histogram

[h, w, ~] = size(img);

% Filtering to remain only handwriting white characters
str_ratio = 1/(1050*1485);

gray = rgb2gray(img);
sharp = imsharpen(gray,'Radius',2,'Amount',2);
er = imerode(sharp, strel('disk', max(floor(6*(w*h*str_ratio)), 1)));
cl = imopen(er, strel('square', 2));
bw = imbinarize(cl, 0.2);
op = bwareaopen(~bw, floor(200*(w*h*str_ratio)));

%% Segmenting rows
y_hist = sum(op, 2);

segments = {};

current_segment = [];

seg_i = 0;
see_w = false;
for y = 1:h
    row_nempty = y_hist(y) > 0;
    if (row_nempty && ~see_w)
        seg_i = seg_i + 1;
        see_w = true;
    elseif (row_nempty && see_w)
        current_segment = [current_segment; op(y,:)];
    end
    
    if (~row_nempty && see_w)
        see_w = false;
        
        if (sum(sum(current_segment)) > 0)
            % figure, imshow(current_segment);
            segments{seg_i} = current_segment;
            current_segment = [];
        end
    end
end

%% Segmenting Digits

% 1. Find white pixel loopong from left to right
% 2. BFS traversal & transfer pixel to black canvas
% 3. Trim digit
% 4. resize to 26*26 and pad 1 pixel border
digits = {};

for si = 1:size(segments, 2)
    seg = segments{si};
    [seg_h, seg_w] = size(seg);
    for x = 1:seg_w
        col_has_white = sum(seg(:,x)) > 0;
        if col_has_white
            % activate BFS
            to_visit = {};
            canvas = zeros(seg_h, seg_w);
            
            initial_y = 0;
            for y = 1:seg_h
                if seg(y, x) ~= 0
                    initial_y = y;
                    break;
                end
            end
            
            to_visit = [to_visit; initial_y, x];
            
            while ~isempty(to_visit)
                % 1. set pixel to black and transfer to canvas
                % 2. get surrounded white pixels to to_visit
                v = to_visit{1};
                vy = v(1);
                vx = v(2);
                
                canvas(vy, vx) = 1;
                seg(vy, vx) = 0;
                
                directions = [
                    vy, vx + 1;
                    vy, vx - 1;
                    vy + 1, vx;
                    vy - 1, vx;
                ];
            
                for d = 1:size(directions)
                    dy = directions(d, 1);
                    dx = directions(d, 2);
                    if (dy > 0 && dy <= seg_h && dx > 0 && dx <= seg_w && seg(dy, dx) && sum(ismember(cell2mat(to_visit'), [dy, dx], 'row')) == 0)
                        to_visit = [to_visit, [dy, dx]];
                    end
                end
                
                to_visit(:, 1) = [];
            end
            
            % trim image
            [nzy, nzx] = find(canvas);
            trimmed = canvas(min(nzy(:)):max(nzy(:)), min(nzx(:)):max(nzx(:)));
            
            digits = [digits, trimmed];
        end
    end
end

digits_set = digits';

