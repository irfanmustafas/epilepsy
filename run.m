addpath('change-detection/')
addpath('change-detection/methods')

try
% [Resolution, Frames per second, Seconds per window, Detection method]
online('MJPG_320x240',25,5,CountPixelsMethod());
catch exception
    disp('An error occurred. Cleaning up.')
    disp(exception.message)
    if exist('vidobj', 'var')
        stop(vidobj);
        clear vidobj
    end
end