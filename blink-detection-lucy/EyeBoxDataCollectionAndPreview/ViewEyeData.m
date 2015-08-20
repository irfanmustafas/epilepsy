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
for i = 1:N
    subplot(211)
    imshow(uint8(eyeData(:,:,i)),'initialmagnification','fit')
    subplot(212)
    plot(y(1:i,1))
    drawnow
end
