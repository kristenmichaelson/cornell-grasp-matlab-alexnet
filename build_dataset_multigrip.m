clear all, close all, clc
tic()
% Collect data from .png, .tiff, and cpos.txt images in the dataset
% Organize into X, Y (training/validation dataset) (archive folders 01-08)
% and X_test, Y_test (archive folders 09-10).
XTrain = zeros(227,227,3,4704);
YTrain = zeros(1,1,6,4704);
NVecTrain = []; % how many ground truth grips per image
XTest = zeros(227,227,3,408);
YTest = zeros(1,1,6,408);
NVecTest = [];

indTrain = 1;
indTest = 1;
for ii = 1:10
    if ii <= 8
        jRange = 0:99; % 100 images in 01-08
    elseif ii == 9
        jRange = 0:49; % 50 images in 09
    else
        jRange = 0:34; % 35 images in 10
    end

    for jj = jRange
        folder_num = sprintf('%02d', ii);
        file_num = sprintf('%02d',jj);

        % Read PNG image
        fname_png = strcat("archive\", folder_num, "\pcd", folder_num, file_num, "r.png");
        I_png = imread(fname_png);

        % Read and normalize .tiff image
        fname_tiff = strcat("archive\", folder_num, "\pcd", folder_num, file_num, "d.tiff");
        I_tiff = imread(fname_tiff);
        % convert to [0 255] uint8 image
        a = min(min(I_tiff));
        b = max(max(I_tiff));
        I_tiff_norm = uint8((I_tiff - a) * (255 / b));

        % X
        % Center crop size 227 * 227
        X = zeros(227, 227, 3);
        X(:,:,1:2) = I_png(127:353, 207:433, 1:2); % R, G channels
        X(:,:,3) = I_tiff_norm(127:353, 207:433); % B channel (substitute depth)
        X = double(X);
        % mean-center
        X = X - 144.0;

        % Y
        fname_cpos = strcat("archive\", folder_num, "\pcd", folder_num, file_num, "cpos.txt");
        f = fopen(fname_cpos);
        data = textscan(f, "%s");
        fclose('all');
        grips = [str2double(data{1}(1:2:end)), str2double(data{1}(2:2:end))];
        s=size(grips);

        % Calculate width
        w=zeros(s(1,1)/4,1);
        for i=2:4:s(1,1)
            w(i,1)=((grips(i,1)-grips(i-1,1))^2+(grips(i,2)-grips(i-1,2))^2)^0.5;
        end
        %w(all(~w,2), :) = [];
        w = w(2:4:end);

        % Calculate height
        h=zeros(s(1,1)/4,1);
        for i=3:4:s(1,1)
            h(i,1)=((grips(i,1)-grips(i-1,1))^2+(grips(i,2)-grips(i-1,2))^2)^0.5;
        end
        %h(all(~h,2), :) = [];
        h = h(3:4:end);

        % Calculate center coordinates
        xcent=zeros(s(1,1)/4,1);
        for i=1:4:s(1,1)
            xcent(i,1)=(grips(i,1)+grips(i+2,1))/2;
        end
        % xcent(all(~xcent,2), :) = [];
        xcent = xcent(1:4:end) - 207; % -207 matches top left corner with crop
        ycent=zeros(s(1,1)/4,1);
        for i=1:4:s(1,1)
            ycent(i,1)=(grips(i,2)+grips(i+2,2))/2;
        end
        %ycent(all(~ycent,2), :) = [];
        ycent = ycent(1:4:end) - 127; % - 127 matches top left corner with crop

        % Calculate rotation angle
        tetha=zeros(s(1,1)/4,1);
        for i=1:4:s(1,1)
            tetha(i,1)=atan2((grips(i,2)-grips(i+1,2)),(grips(i,1)-grips(i+1,1)));
        end
        %tetha(all(~tetha,2), :) = [];
        tetha = tetha(1:4:end);
        %sin2tetha=zeros(s(1,1)/4,1);
        %cos2tetha=zeros(s(1,1)/4,1);

        % Outputs
        sin2tetha=sin(2*tetha);
        cos2tetha=cos(2*tetha);
        % Y=[xcent(1,1),ycent(1,1),sin2tetha(1,1),cos2tetha(1,1),h(1,1),w(1,1)];
        Y = [xcent'; ycent'; sin2tetha'; cos2tetha'; h'; w'];
        
%         if sum(isnan(Y(:))) > 0 % need to manually take NaN's out of pcd0165cpos.txt
%             continue
%         end
        
        % Number of grips
        N = s(1,1)/4;
        
        % Fill in train, test matrices
        if ii <= 8
            XTrain(:,:,:,indTrain:indTrain+N-1) = repmat(X,1,1,1,N);
            YTrain(:,:,:,indTrain:indTrain+N-1) = reshape(Y,1,1,6,N);
            indTrain = indTrain + N;
            NVecTrain = [NVecTrain; N];
        else
            XTest(:,:,:,indTest:indTest+N-1) = repmat(X,1,1,1,N);
            YTest(:,:,:,indTest:indTest+N-1) = reshape(Y,1,1,6,N);
            indTest = indTest + N;
            NVecTest = [NVecTest; N];
        end
    end
end

t = toc()

clearvars -except XTrain YTrain XTest YTest NVecTrain NVecTest net1


