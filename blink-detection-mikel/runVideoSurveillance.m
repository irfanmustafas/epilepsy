
% video = VideoReader('../Video/prueba2Reducido.mp4');
% numFrames = get(video, 'NumberOfFrames');
% video = VideoReader('../Video/pruebaReducido.mp4');
% video = VideoReader('../Video/prueba2Reducido.mp4'); % Camera moves,
% nonsense to work on it
% video = VideoReader('C:\Users\Mikel\Pictures\Archivos de LifeCam\Hartu 3 (02-07-2015 12-58).wmv');
% video = VideoReader('C:\Users\Mikel\Pictures\Archivos de LifeCam\Hartu 4 (02-07-2015 13-09).wmv');
% video = VideoReader('C:\Users\Mikel\Pictures\Archivos de LifeCam\Hartu 5 (02-07-2015 13-14).wmv');

% video = 'C:\BlinkingEpilepsy\VideosEpilepsy\2015 07 04 Waking up & Buccal.mp4';
% video = 'C:\BlinkingEpilepsy\VideosEpilepsy\Videos\No siezure\2015 06 20 Normal going to sleep.mp4';



% video = 'C:\BlinkingEpilepsy\VideosEpilepsy\Videos\No siezure\2015 06 27 going to sleep.mp4';

video = '../data/video5.mp4';



vs = VideoSurveillance();
vs.initialize(video);
vs.run();