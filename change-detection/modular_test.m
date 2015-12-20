addpath 'C:\Users\willf\Pictures\blinks\72cm.seated.light.nomove'

video = VideoReader('1280x720.mp4');

changeFrames = [];

d = modular.Detector(video);

d.eyeExtractor = modular.extraction.PointTrackingEyeExtractor();

d.step_callback = @step_callback;
d.change_callback = @(frame)[changeFrames frame];

d.go();