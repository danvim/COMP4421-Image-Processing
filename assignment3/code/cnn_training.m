d = load('mnist.mat');

X4D = load('X4D.mat');
Xtest4D = load('Xtest4D.mat');
X = X4D.X4D;
Xtest = Xtest4D.Xtest4D;
Y = d.trainY;
Ytest = d.testY;

% i = reshape(X(3,:), 28, 28)'; imshow(i); Y(3);

layers = [
    imageInputLayer([28 28 1])
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer
    ];

options = trainingOptions('adam', 'MaxEpochs', 2, 'Plots', 'training-progress');

m = trainNetwork(X, categorical(Y'), layers, options);

save 'cnn-1y-d' m;

YPred = classify(m, Xtest);
YValidation = categorical(Ytest');

accuracy = sum(YPred == YValidation)/numel(YValidation);

display(accuracy);