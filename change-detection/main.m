clear all;
clc;
close all;

%addpath('../data');
%addpath('methods/');
addpath 'C:\Users\willf\Pictures\blinks\72cm.seated.light.move'

video = VideoReader('1280x720.mp4');

method = exmethods.CountPixelsMethod();

FRAMES_PER_SECOND = 25;
bd = BlinkDetector(FRAMES_PER_SECOND);
bd.setExtractorMethod(method);
bd.secondsPerWindow = 10;
helpers = HelperFunctions(bd);

%video = VideoReader('video4.wmv');
%video = VideoReader('320x180.mp4');

firstFrame = video.readFrame;

figure; imshow(uint8(zeros(480,640,3))); hold on;

while video.hasFrame()
    frame = video.readFrame;
    helpers.step(frame);
end