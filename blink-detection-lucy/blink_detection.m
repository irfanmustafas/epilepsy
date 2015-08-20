function [b, eyebuff] = ...
    blink_detection(eyebuff, eyeImage, PARAM)

global flag_lost

if nargin == 2
    blink_buffer_size = 10;
    grey_threshold = 15;
    noise_threshold = 0.05;
    blink_threshold = 0.3;
else
    blink_buffer_size = PARAM.blink_buffer_size;
    grey_threshold = PARAM.grey_threshold;
    noise_threshold = PARAM.noise_threshold;
    blink_threshold = PARAM.blink_threshold;
end

b = 0; % blink indicator

if size(eyebuff,3) < blink_buffer_size
    eyebuff(:,:,end+1) = eyeImage; % append to eye buffer
else
    % check the difference with the eye buffer
    mean_eye_buff = mean(eyebuff,3);
    y = mean2(abs(mean_eye_buff-eyeImage) > grey_threshold);
    if y > noise_threshold && y < blink_threshold
        b = 1; % blink detected
        eyebuff = eyebuff(:,:,end); % re-initialise the eye buffer
        % so that the blink image is not included
        % (maybe we can keep the last K images? half of the buffer?)
    elseif y <= noise_threshold
        % static image - no blink
        eyebuff(:,:,1) = [];
        eyebuff(:,:,end+1) = eyeImage; % circle-shift and add the "static" 
        % image to the eye buffer
    else
        flag_lost = true; % lost track due to too much noise
    end
end
