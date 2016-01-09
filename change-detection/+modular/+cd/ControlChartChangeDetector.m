classdef ControlChartChangeDetector < modular.cd.AbstractChangeDetector
    %CONTROLCHARTCHANGEDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        deviations = 2;
    end
    
    methods
        
        function obj = ControlChartChangeDetector(window_size)
            obj@modular.cd.AbstractChangeDetector(window_size);
        end
        
        function c = doProcess(this)
            normalised = 1-zscore(this.window);
            
            c = 0;
            if abs(normalised(end)) > this.deviations*std(normalised)
                c = 1;
            end

        end
    end
    
end

