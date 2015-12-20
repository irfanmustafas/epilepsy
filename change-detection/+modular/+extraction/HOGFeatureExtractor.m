classdef HOGFeatureExtractor < modular.extraction.AbstractImageFeatureExtractor
    %HOGFEATUREEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        kSize = [2 2]
    end
    
    methods
        function obj = HOGFeatureExtractor(kSize)
            obj.kSize = kSize;
        end
        
        function features = getFeatures(this, image)
            features = extractHOGFeatures(image, 'CellSize', this.kSize);
        end
    end
    
end

