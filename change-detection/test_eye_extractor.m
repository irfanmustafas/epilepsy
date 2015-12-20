clear all, clc, close all;

addpath 'C:\Users\willf\Pictures\blinks\72cm.seated.light.nomove'

video = VideoReader('1280x720.mp4');

pte = modular.extraction.PointTrackingEyeExtractor;

while video.hasFrame()
    frame = video.readFrame;

    eye = pte.getEyeImage(frame);
    subplot(1,2,1);
    imshow(frame);
    subplot(1,2,2);
    imshow(eye);
    drawnow;
end