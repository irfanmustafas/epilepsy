classdef IWindowingStrategy < handle
    %WINDOWINGSTRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        W1 = [];
        W1_size;
        W2 = [];
        W2_size;
    end
    
    methods(Abstract)
        append(obj, newData);
    end
    
    methods
        function obj = IWindowingStrategy(W1_size, W2_size)
            obj.W1_size = W1_size;
            obj.W2_size = W2_size;
        end
    end
    
end

