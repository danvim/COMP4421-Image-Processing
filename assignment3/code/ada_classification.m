function accuracy = ada_classification(digits_set)

% Classify the digits by adaboost
% digits_set: a matrix that stores the segmented digits. The number of rows
%            equal to the number of digits in the iuput image. Each digit 
%            is stored in each row.
% accuracy: the classified accuracy of the adaboost algorithm.

% Remember to train the adaboost classifier firstly.

%% Run prediction

ada = load('ada.mat');
categories = categorical([0,1,2,3,4,5,6,7,8,9]);

for i = 1:size(digits_set, 1)
    trimmed = digits_set{i};
    [ty, tx] = size(trimmed);
            
    % pad to square
    max_l = max([ty, tx]);
    padded = zeros(max_l, max_l);
    py = floor((max_l - ty)/2) + 1;
    px = floor((max_l - tx)/2) + 1;
    padded(py:py+ty-1, px:px+tx-1) = trimmed;

    % resize
    im26 = imresize(padded, [26 26]);
    im28 = padarray(im26, [1, 1], 'both');
    
    confidence = zeros([1, 10]);
    
    for j = 1:size(ada.alphas, 2)
        confidence = confidence + ada.alphas(j) * ismember(categories, classify(ada.selected_wc(j), uint8(255*im28)));
    end
    
    [~, max_i] = max(confidence);
    
    imwrite(trimmed, ['../result images/results/', int2str(i), '-', int2str(max_i - 1), '.png']);
end

accuracy = 1;