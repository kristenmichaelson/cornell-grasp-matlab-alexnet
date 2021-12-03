% NVecTest contains # of ground truth grips for each unique image. Accept
% grasps that satisfy rectangle metric for at least one ground truth grasp.

M = length(NVecTest); % number of unique test images
NGoodGrips = 0;
ind = 1;

for ii = 1:M
    goodGripFlag = 0;
    N = NVecTest(ii);
    for jj = 1:N % check each ground-truth grip in an image and see if the NN output satisfies rectangle metric for any of them
        angleFlag = 0;
        jaccardFlag = 1;
        Y = predict(net, XTest(:,:,:,ind));
        Y = Y(:);
        YTrue = YTest(:,:,:,ind);
        YTrue = YTrue(:);
        
        % Check angle within 30 deg
        a = 180/pi * atan2(Y(3),Y(4)) / 2;
        aTrue = 180/pi * atan2(YTrue(3),YTrue(4)) / 2; 
        if abs(a - aTrue) <= 30
            angleFlag = 1;
        end
        
        % Jaccard index
        xc = Y(1); yc = Y(2);
        h = Y(5); w = Y(6);
        xcTrue = YTrue(1);
        ycTrue = YTrue(2);
        hTrue = YTrue(5);
        wTrue = YTrue(6);
        
        % Compute corners of output rectangle
        R = [cosd(a) -sind(a); sind(a) cosd(a)];
        c= [w/2, h/2;
            -w/2, h/2; 
            -w/2, -h/2;
            w/2, -h/2]';
        c = R * c + [xc; yc];
        
        % Compute corners of true rectangle
        RTrue = [cosd(aTrue) -sind(aTrue); sind(aTrue) cosd(aTrue)];
        cTrue = [wTrue/2, hTrue/2; 
                 -wTrue/2, hTrue/2;
                 -wTrue/2, -hTrue/2;
                 wTrue/2, -hTrue/2]';
        cTrue =  RTrue * cTrue + [xcTrue; ycTrue];
        
        NMonte = 500;
        Nunion = 0;
        Nintersection = 0;
        for kk = 1:NMonte % Monte Carlo approximation
            % Generate a random point in 227x227
            xMC = 227 * rand();
            yMC = 227 * rand();
            
            if inpolygon(xMC, yMC, cTrue(1,:), cTrue(2,:)) && inpolygon(xMC, yMC, c(1,:), c(2,:))
                Nunion = Nunion + 1;
                Nintersection = Nintersection + 1;
            elseif inpolygon(xMC, yMC, cTrue(1,:), cTrue(2,:)) || inpolygon(xMC, yMC, c(1,:), c(2,:))
                Nunion = Nunion + 1;
            end
            
            %%%
%             scatter(cTrue(1,:), cTrue(2,:), '*b');
%             hold on; scatter(c(1,:), c(2,:), '*c'); 
%             hold on; scatter(xMC, yMC, '*r');
%             axis equal
%             hold off
            %%%

        end
        if Nintersection/Nunion >= 0.25
%             Nintersection/Nunion
            jaccardFlag = 1;
        end
        
        %%% Easier test %%%
%         if norm([xc; yc] - [xcTrue; ycTrue]) < 25
%             jaccardFlag = 1;
%         end
        %%%
        
        if jaccardFlag && angleFlag
            goodGripFlag = 1; % found a good grip!
        end
        
        ind = ind + 1;
    end
    
    if goodGripFlag
        NGoodGrips = NGoodGrips + 1;
    end
end


NGoodGrips/M        
        