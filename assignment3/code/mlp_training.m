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
   
    fullyConnectedLayer(512)
    reluLayer
    dropoutLayer
    
    fullyConnectedLayer(512)
    reluLayer
    dropoutLayer
    
    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer
    ];

options = trainingOptions('adam', 'MaxEpochs', 5, 'Plots', 'training-progress');

m = trainNetwork(X, categorical(Y'), layers, options);

save 'mlp' m;

YPred = classify(m, Xtest);
YValidation = categorical(Ytest');

accuracy = sum(YPred == YValidation)/numel(YValidation);

display(accuracy);