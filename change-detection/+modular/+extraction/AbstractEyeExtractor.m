classdef AbstractEyeExtractor < handle
    %ABSTRACTEYEEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Abstract)
        eye = getEyeImage(input);
    end
    
end

