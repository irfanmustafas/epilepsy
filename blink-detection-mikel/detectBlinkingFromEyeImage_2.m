function [blinking_ lost] = detectBlinkingFromEyeImage_2(image, videoFrame)
blinking_ = false;
% image = double(image) .^ 4;
% image = uint8(image ./ max(image(:))*255);
image2 = image;
% image = imgaussfilt(image, 2);


lost = false;
global allMeans;
global allMeansAux;
global myplot;
global myplot2;
global inarrow;
global blinking;
global blinkingCount;

if (isempty(allMeans))
    next = 1;
else
    next = size(allMeans, 3) + 1;   
end

if (~isempty(allMeans))
    image = imresize(image, [size(allMeans, 1) size(allMeans, 2)]);
end

allMeans(:, :, next) = double(image);



med = mean(allMeans, 3);

image =  uint8(abs(double(image) - med));
med = uint8(med);


if (next > 10)
    dif = sum(double(image(:)).^4);
    
    aux =double(image(:)).^2;
    dif = sum(aux > 15^2);
%     dif = sum(double());
    % if length(myplot) > 4
    %     dif = (sum(myplot(end-3: end)) + dif) / 5;
    % end
    myplot = [myplot dif];
%     subplot(4, 1, 4)
    plot(myplot)
    hold on
    auxmyplot = myplot(max(1, length(myplot) - 100) : end);  %200
    threshold = mean(auxmyplot) + 0.2 * std(auxmyplot);
    
    myplot2 = [myplot2 threshold];
    plot(myplot2, 'r');
    hold off
    
    if (dif > mean(auxmyplot) + 0.2 * std(auxmyplot))  % 0.2 very good 0.8 also
%         auxmyplot(end) = mean(auxmyplot);

        inarrow = inarrow + 1;
%         if (isempty(allMeansAux))
%             nextAux = 1;
%         else
%             nextAux = size(allMeansAux, 3) + 1;
%         end
%         allMeansAux(:, :, nextAux) = allMeans(:, :, end);
        allMeans(:, :, end) = [];
%         if (size(allMeansAux, 3) > 10)
%             allMeansAux(:, :, 1) = [];
%         end
        if (inarrow == 0)
            allMeans(:, :, end) = [];
        elseif (inarrow > 60)
            allMeans = [];
%             allMeans = allMeansAux;
            disp('Ouch! It wasn''t a blink!');
            blinking = false;
            blinkingCount = blinkingCount - 1;
            inarrow = 0;
            myplot = [];
            lost = true;
        elseif (~blinking)
            blinkingCount = blinkingCount + 1;
            disp(['Blinking starts! ', num2str(blinkingCount)]);
            blinking = true;
        end
    elseif (dif < mean(auxmyplot)) 
        inarrow = 0;
        if (blinking)
            disp(['Blinking ends!!! ', num2str(blinkingCount)]);
            allMeansAux = [];
        end
        blinking = false;
    end
end

if (size(allMeans, 3) > 10)
    allMeans(:, :, 1) = [];
end

% cols = size(image, 2);
% half = floor(cols / 2);
% leftImage = image(:, 1 : half);
% rightImage = image(:, half + 1 : end);
% 
% [~, leftEyePos] = max(leftImage(:));
% [~, rightEyePos] = max(rightImage(:));
% 
% [leftPosR leftPosC] = ind2sub(size(leftImage), leftEyePos);
% [rightPosR rightPosC] = ind2sub(size(rightImage), rightEyePos);

% blinking = false;

% level = graythresh(image);
% % BW = im2bw(image, double(max(image(:)) - 20) / 255);
% % imshow(BW);

% regions = detectMSERFeatures(I);
% imshow(I); hold on;
%     plot(regions, 'showPixelList', true, 'showEllipses', false);
%     hold off;


% hold on;
% plot(regions);


% 
% subplot(4, 1, 1)
% imshow(med, [0, 255]);
% 
% subplot(4, 1, 2)
% imshow(image, [0, 30]);
% 
% 
% subplot(4, 1, 3)
% imshow(image2, [0, 255]);

% % leftImage1 = med(:, 1 : half);
% % rightImage1 = med(:, half + 1 : end);
% % 
% % 
% % subplot(3, 2, 1)
% % % I = leftImage;
% % % % imshow(I); 
% % % level = graythresh(I);
% % % BW = im2bw(I, level);
% % imshow(leftImage1, []);
% % 
% % subplot(3, 2, 2)
% % % I = rightImage;
% % % % imshow(I); 
% % % level = graythresh(I);
% % % BW = im2bw(I, level);
% % imshow(rightImage1, []);
% % 
% % subplot(3, 2, 3)
% % imshow(leftImage, []);
% % subplot(3, 2, 4)
% % imshow(rightImage, []);
% % 
% % subplot(3, 2, 6)
% % imshow(videoFrame)
% % drawnow;
% % 
% % global ourMovie;
% % global nextFrame;
% % 
% % global fig;
% % 
% % ourMovie(nextFrame) = getframe(fig);
% % nextFrame = nextFrame + 1;

drawnow;
