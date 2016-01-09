clc;
close all;
clear all;
warning off;

path = 'C:\Users\willf\Pictures\blinks\72cm.seated.light.nomove';
addpath(path);
addpath('./output');
load labels;
labels = labels - 1;
extension = '.mp4';
resolutions = {'1280x720'};% '640x480' '320x180'};% '160x90'};

for i=1:numel(resolutions)
    res = resolutions{i};
    file = [res extension];
    
    fprintf('Processing %s...', file);
    video = VideoReader(file);
    changeFrames = [];
    
    d = modular.Detector(video);
    d.featureExtractor = modular.extraction.CornerDensityFeatureExtractor();
    %d.featureExtractor = modular.extraction.CountPixelsFeatureExtractor();
    d.eyeExtractor = modular.extraction.PointTrackingEyeExtractor();
    d.changeDetector = modular.cd.ControlChartChangeDetector(50);
    
    tic;
    while(video.hasFrame())
        d.processNextFrame();
    end
    time = toc;
    
    fprintf(' Done. (%.2fs)\n', time);
    
    st = d.st;
    
    [~, results{i}] = controlchart(st,'display','off','chart','mr');
    plotdata = results{i};
    detections = plotdata.pts > plotdata.ucl | plotdata.pts < plotdata.lcl;
    pretty_print_results(labels, detections);
    %[tp, fp, fn, n] = calculate_accuracies(results{i}, labels);
    %fprintf('%s: %.2f%% (%d/%d) blinks registered\n\n',resolutions{i},(tp/n)*100, tp, n);
end



