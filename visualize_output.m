% pick 100 random images and plot a corresponding grip center
% indices = randperm(4704,100); 
% indices = 1:100;
indices = 1:408;
for ind = indices
    I = XTrain(:,:,:,ind);
    YTrue = YTrain(:,:,:,ind);
    aTrue = -180/pi*atan2(YTrue(3),YTrue(4))/2;
    Y = predict(net, I);
    a = -180/pi*atan2(Y(3),Y(4))/2;
    figure(1); imshow(I);
    drawRectangleonImageAtAngle(1, 'red', [Y(1); Y(2)],Y(6), Y(5), a)
    drawRectangleonImageAtAngle(1, 'blue', [YTrue(1); YTrue(2)],YTrue(6), YTrue(5), aTrue)
end