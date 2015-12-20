classdef CountPixelsFeatureExtractor

    %HOGFEATUREEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        threshold = 0.4;
    end
    
    methods
        function features = getFeatures(this, image)

            if ~islogical(image)
                image = histeq(image);
                image = im2bw(image, this.threshold);
            end

            whitePixels = sum(image(:));
            blackPixels = numel(image) - whitePixels;
            features = blackPixels;
            
        end
    end

end

