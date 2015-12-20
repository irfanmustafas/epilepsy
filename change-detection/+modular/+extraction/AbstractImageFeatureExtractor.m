classdef AbstractImageFeatureExtractor < handle
    %ABSTRACTIMAGEFEATUREEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here

    methods (Abstract)
        features = getFeatures(image)
    end
    
end

