clc;
close all;
clear all;

path = 'C:\Users\willf\Pictures\blinks\72cm.seated.light.nomove';
addpath(path);

extension = '.mp4';
resolutions = {'1280x720' '640x480' '320x180' '160x90'};

for i=1:numel(resolutions)
    
    res = resolutions{i};
    file = [res extension];
    video = VideoReader(file);
    changeFrames = [];
    
    d = modular.Detector(video);
        
    d.eyeExtractor = modular.extraction.PointTrackingEyeExtractor();
    d.changeDetector = modular.cd.ControlChartChangeDetector(75);
    
    %d.step_callback = @step_callback;
    
    tic;
    while(video.hasFrame())
        blink = d.processNextFrame();
        if blink
            frameNo = numel(d.st);
            fprintf('%s > change @ frame #%d\n', file, frameNo); 
            changeFrames = [changeFrames frameNo];
        end
    end
    time = toc;
    
    st = d.st;
    %d.change_callback = @(frame) changeFrames = [changeFrames frame];
    %d.go();

    save([path '\' res '.mat'], 'changeFrames', 'time', 'st');
    
end



