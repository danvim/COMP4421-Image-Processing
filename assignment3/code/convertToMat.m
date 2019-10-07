% This script converts the mnist mat dataset into the required 4D version
% for network training.

d = load('mnist.mat');

X = d.trainX;
Xtest = d.testX;

X4D = [];
Xtest4D = [];

for i = 1:60000
    X4D = cat(4, X4D, reshape(X(i,:), 28, 28)');
end

for i = 1:10000
    Xtest4D = cat(4, Xtest4D, reshape(Xtest(i,:), 28, 28)');
end

save 'x4d' X4D;

save 'xtest4d' Xtest4D;