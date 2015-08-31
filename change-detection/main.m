clear all;
clc;
close all;

addpath('../data');
addpath('methods/');

method = CountPixelsMethod();

FRAMES_PER_SECOND = 25;
bd = BlinkDetector(FRAMES_PER_SECOND);
bd.setExtractorMethod(method);
bd.secondsPerWindow = 10;
helpers = HelperFunctions(bd);

%video = VideoReader('video4.wmv');
video = VideoReader('video1.mp4');

firstFrame = video.readFrame;
bd.bwThreshold = estimate_threshold(firstFrame);

figure; imshow(uint8(zeros(480,640,3))); hold on;

while video.hasFrame()
    frame = video.readFrame;
    helpers.step(frame);
end