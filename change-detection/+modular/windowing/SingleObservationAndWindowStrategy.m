classdef SingleObservationAndWindowStrategy < IWindowingStrategy
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function obj = SingleObservationAndWindowStrategy(WINDOW_SIZE)
            obj@IWindowingStrategy(WINDOW_SIZE,1);
        end
        
        function append(this, newData)

        end
    end
    
end

