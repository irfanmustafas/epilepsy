function [ threshold ] = estimate_threshold( frame )
    %ESTIMATE_THRESHOLD Estimate a threshold for generating blink detection
    %features.
    %   Detailed explanation goes here
    eyesDetector = vision.CascadeObjectDetector('EyePairBig');

    filtered = imgaussfilt(histeq(rgb2gray(frame)));

    eyesBB = step(eyesDetector, filtered);

    if isempty(eyesBB)
        error('Could not extract eye image')
    end

    cropped = imcrop(filtered, eyesBB(1,:));

    ratio = 1;
    threshold = 0;

    while ratio > 0.75
        threshold = threshold + 0.05;
        bw = im2bw(cropped, threshold);
        ratio = sum(bw(:) == 1) / numel(bw);
    end

end

