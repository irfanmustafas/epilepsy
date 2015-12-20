classdef AbstractMethod < handle
    
    methods
        function this = AbstractMethod()
        end
    end
    
    methods (Abstract)
        st = extract(bwEyeIm);
    end
    
end

