% Pre-trained AlexNet
% https://www.mathworks.com/help/deeplearning/ref/alexnet.html;jsessionid=d98f6c1f3b6bb030eccbf5384844
tic
net = alexnet; % alexnet pre-trained on ImageNet data (equivalent to net = alexnet('Weights', 'imagenet'))
% analyzeNetwork(net) % shows layer types, activations, weights, etc 

layersTransfer = net.Layers(2:end-3); % cut off classification and output layers
layers = [
    imageInputLayer([227 227 3], 'Normalization', 'none')
    layersTransfer
    fullyConnectedLayer(6) %, 'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    regressionLayer]; % add last fully connected layer with 6 channels

options = trainingOptions('adam', ...
                          'InitialLearnRate',5e-4, ...
                          'MaxEpochs',25, ...
                          'L2Regularization', 1e-3, ... % weight decay
                          'ValidationData', {XTrain(:,:,:,4001:4704), YTrain(:,:,:,4001:4704)}, ...
                          'Plots', 'training-progress');
                      
net = trainNetwork(XTrain(:,:,:,1:4000), YTrain(:,:,:,1:4000), layers, options)                      

t = toc()