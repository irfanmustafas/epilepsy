classdef CascadeEyeExtractor < modular.extraction.AbstractEyeExtractor
    %CASCADEEYEEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        extractor = vision.CascadeObjectDetector('EyePairBig');
    end
    
    methods
        function eye = getEyeImage(this, input)
            bb = step(this.extractor, input);
            eye = imcrop(input, bb);
            %eye = imresize(eye, [150,500]);
        end
    end
    
end

