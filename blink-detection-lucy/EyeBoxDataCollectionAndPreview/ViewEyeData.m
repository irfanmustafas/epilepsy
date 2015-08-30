clear all
clc
close all
load eyeData

%% % PCA + CLUSTERING - does not work
a = [];
for i = 1:size(eyeData,3)
    x = eyeData(:,:,i);
    a(i,:) = (x(:)');
end
fprintf('Data reshaped.\n')
[~,y] = pca(a);
plot(y(:,1),y(:,2),'k.')

% z = y(:,1:20); % data to be clustered
% 
% for k = 2:10
%     idx = kmeans(z,k);
%     t = figure;
%     hold on
%     title([num2str(k) 'clusters'])
%     for j = 1:k
%         figure(t)
%         plot(z(idx == j,1),z(idx == j,2),'k.','color',rand(1,3))
%         eyeImg = mean(eyeData(:,:,idx == j),3);
%         figure(1)
%         imshow(uint8(eyeImg),'initialmagnification','fit')
%         pause
%     end
%
% end

%% View change possibility
N = size(eyeData,3);
D = zeros(1,N);

eyePair = vision.CascadeObjectDetector('EyePairBig');
eye = vision.CascadeObjectDetector('RightEye');

threshold = 1;

df = zeros(1,N);

for i = 1:N
    eq = histeq(uint8(eyeData(:,:,i)));
    %eq = uint8(eyeData(:,:,i));
    
    eyesBB = step(eyePair, eq);
    
    h(:,i) = imhist(imcrop(eq, eyesBB(1,:)));
    if i > 1
       %df(i) = sum(h(:,i) - mean(h,2)); 
       [~, df(i)] = ttest(h(:,i-1),h(:,i));
       %[~, df(i)] = SPLL(h(:,i-1),h(:,i));
    end
    
    eyeBB = step(eye, eq);
    
    subplot(411)
    imshow(imfilter(eq, fspecial('sobel')));
    %imshow(edge(eq,'canny', 0.6, 1),'initialmagnification','fit')
    
    for j=1:size(eyesBB,1)
        if df(i) >= threshold
            color = 'r';
        else
            color = 'b';
        end
        rectangle('Position',eyesBB(j,:),'LineWidth',4,'LineStyle','-','EdgeColor',color);
    end
    subplot(412)
    plot(y(1:i,1))
    subplot(413)
    
    crop = imcrop(eq, eyesBB(1,:));
    histogram(crop);
    
    subplot(414)
    
    BW = imfilter(crop, fspecial('sobel'));%edge(crop,'canny');
    [H,T,R] = hough(BW,'RhoResolution',0.5,'Theta',-90:0.5:89.5);
    
    imshow(imadjust(mat2gray(H)));
    colormap(hot)
    %plot(1:size(eq,1), mean(eq,2), 'r')
    %axis([0 30 20 60]);
    %plot(df(1:i), 'b-');

    drawnow
end
