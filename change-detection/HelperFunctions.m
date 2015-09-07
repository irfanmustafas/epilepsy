classdef HelperFunctions < handle

    properties (Access = public)
        bd;
        st;
        data;
        blinks = 0;
    end
    
    methods
        function this = HelperFunctions(detector)
            this.bd = detector;
        end
        
        function showFrame(this, frame)
            imshow(frame);
            
            if isempty(frame)
                return
            end
            
            if ~isempty(this.bd.eyesBB)
                if this.bd.change
                    rectangle('Position', this.bd.eyesBB(1,:), 'EdgeColor', 'Red');
                else
                    rectangle('Position', this.bd.eyesBB(1,:), 'EdgeColor', 'Blue');
                end
            end
        end
        
        function processFrame(this, frame)
            if isempty(frame)
                return
            end
            
            this.bd.processFrame(frame);
        end
        
        function step(this, frame)
            this.processFrame(frame);
            if this.bd.ready
                this.data = [this.data this.bd.nst];
            end
            subplot(3,1,1);
            imshow(this.bd.bwim);
            subplot(3,1,2);
            this.showFrame(frame);
            subplot(3,1,3);
            plot(this.data, 'b-', 'LineWidth', 2);
            hold on;
            if this.bd.change
                this.blinks = this.blinks + 1;
                plot(length(this.data), this.data(end), 'ro', 'MarkerSize', 10);
                xlabel(sprintf('%d blinks', this.blinks));
            end
            drawnow;
        end
        
        function stepHiPerf(this, frame)
           this.processFrame(frame); 
           if this.bd.ready
                this.data = [this.data this.bd.nst];
           end
           
           plot(this.data, 'b-', 'LineWidth', 2);
           hold on;
           if this.bd.change
               this.blinks = this.blinks + 1;
               plot(length(this.data), this.data(end), 'ro', 'MarkerSize', 10);
               xlabel(sprintf('%d blinks', this.blinks));
           end
           drawnow;
        end
    end
    
end

