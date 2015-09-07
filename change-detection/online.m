addpath('methods/');

FRAMES_PER_SECOND = 25;
bd = BlinkDetector(FRAMES_PER_SECOND);
bd.setExtractorMethod(CountPixelsMethod());
bd.secondsPerWindow = 5;
helpers = HelperFunctions(bd);

timerFcn = @(vid,event) helpers.step(peekdata(vid,1));

vidobj = videoinput('winvideo',1,'MJPG_640x480');
triggerconfig(vidobj, 'manual');

set(vidobj, 'TimerPeriod', 1/FRAMES_PER_SECOND);
set(vidobj, 'TimerFcn', timerFcn);

figure; imshow(uint8(zeros(480,640,3))); hold on;

start(vidobj);
pause(30);
stop(vidobj);


