classdef AbstractChangeDetector < handle
    %ABSTRACT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        window = [];
        window_size = 0;
        change;
        st;
    end
    
    methods (Abstract, Static)
        c = doProcess(this);
    end
    
    methods
        
        function obj = AbstractChangeDetector(window_size)
            obj.window_size = window_size;
        end
        
        function append(this, newData)
            this.st = newData;
            if size(this.window,1) < this.window_size
                if isempty(this.window)
                    this.window(1,:) = newData;
                else
                    this.window = [this.window; newData];
                end
            else
                this.change = this.doProcess();
                this.window = [this.window(2:end,:); newData];
            end
        end
        
        function ready = hasSufficientData(this)
            ready = size(this.window,1) == this.window_size;
        end
    end
    
end

