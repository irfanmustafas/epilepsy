function [ output_args ] = step_callback( nextFrame, eye, features, st )
%STEPCALLBACK Summary of this function goes here
%   Detailed explanation goes here

    subplot(2,1,1);
    plot(st);
    subplot(2,1,2);
    imshow(eye);
    drawnow;
end

