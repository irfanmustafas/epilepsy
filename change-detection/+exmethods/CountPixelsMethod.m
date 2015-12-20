classdef CountPixelsMethod < exmethods.AbstractMethod
    
    methods
        function st = extract(~, bwEyeIm)
            whitePixels = sum(bwEyeIm(:));
            blackPixels = numel(bwEyeIm) - whitePixels;
            st = blackPixels;
        end
    end
    
end

