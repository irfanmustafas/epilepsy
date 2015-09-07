function online(resolution, FPS, secondsPerWindow, method)

bd = BlinkDetector(FPS);
bd.setExtractorMethod(method);
bd.secondsPerWindow = secondsPerWindow;
helpers = HelperFunctions(bd);

timerFcn = @(vid,event) helpers.step(peekdata(vid,1));

global vidobj 
vidobj = videoinput('winvideo',1,resolution);
triggerconfig(vidobj, 'manual');

set(vidobj, 'TimerPeriod', 1/FPS);
set(vidobj, 'TimerFcn', timerFcn);

figure; imshow(uint8(zeros(480,640,3))); hold on;

start(vidobj);
pause(30);
stop(vidobj);

end

