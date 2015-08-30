clear all;
clc;
close all;

addpath('../data');

%video = VideoReader('video4.wmv');
video = VideoReader('video2.mp4');

lEye = vision.CascadeObjectDetector('LeftEye');
rEye = vision.CascadeObjectDetector('RightEye');

figure;
hold on;

means = [];

while video.hasFrame()
    frame = video.readFrame;
    gs = imgaussfilt(histeq(rgb2gray(frame)));
    l = step(lEye, frame);
    leftEyeIm = imcrop(gs,l(1,:));
    r = step(rEye, frame);
    rightEyeIm = imcrop(gs,r(1,:));
    
    
    
    disp(size(leftEyeIm))
    
    subplot(3,2,1)
    imshow(frame);
    subplot(3,2,2)
    imshow(gs);
    
    rectangle('position',l(1,:),'EdgeColor','r');
	rectangle('position',r(1,:),'EdgeColor','r');
    
    subplot(3,2,3)
    imshow(leftEyeIm)
    subplot(3,2,4)
    imshow(rightEyeIm)
    subplot(3,2,5)
    %imshow(edge(leftEyeIm, 'canny'))
    lsobel = imfilter(leftEyeIm, fspecial('sobel'));
    %imshow(imresize(lsobel, [20,20]))
    bw = im2bw(leftEyeIm);
    imshow(bw)
    subplot(3,2,6)
    %imshow(edge(rightEyeIm, 'canny'))
    %imshow(imfilter(rightEyeIm, fspecial('sobel')))
    means = [means mean(bw(:))];
    plot(means);
    %histogram(lsobel);
    drawnow;
    
end