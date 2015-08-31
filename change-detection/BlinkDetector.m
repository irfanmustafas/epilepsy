classdef BlinkDetector < handle
    
    properties (Access = private)
        window = [];
        windowNormalised = [];
        windowSize = 0;
        eyesDetector = vision.CascadeObjectDetector('EyePairBig');
    end
    
    properties (Access = public)
        change = 0;
        st = 0;
        nst = 0;
        eyesBB;
        bwim = [];
        bwThreshold = 0;
        ready = 0;
        secondsPerWindow = 3;
        extractorMethod;
    end
    
    methods (Access = public)
        % Constructor
        function this = BlinkDetector(fps)
            % Window size is open to interpretation. Ideally the window
            % should contain some example of blinking to maintain a
            % sensible activation threshold from std dev. 
            this.windowSize = ceil(fps)*3;
            
        end
        
        % Process a new frame
        function processFrame(this, frame)
            
            % 1. Convert to grayscale  (Homogenise)
            % 2. Equalise histogram    (Homogenise)
            % 3. Apply gaussian filter (Denoise)
            filtered = imgaussfilt(histeq(rgb2gray(frame)));
            
            % Naive rule of thumb for threshold if not specified.
            if this.bwThreshold == 0
                this.bwThreshold = 1-mean(im2double(filtered(:)));
            end
            
            this.eyesBB = step(this.eyesDetector, filtered);
            
            if isempty(this.eyesBB)
                return;
            else
                % Crop, threshold to binary and pass to extractor method.
                eyes = imcrop(filtered,this.eyesBB(1,:));
                this.bwim = im2bw(eyes, this.bwThreshold);
                this.st = this.extractorMethod.extract(this.bwim);
            end
            
            this.change = 0;
            if length(this.window) < this.windowSize
                % Grow window
                this.window = [this.window this.st];
            elseif length(this.window) > this.windowSize
                % Discard oldest point
                this.window = this.window(2:end);
            else
                % Normalise window and detect change; grow window.
                this.ready = 1;
                this.windowNormalised = 1-zscore(this.window);
                this.nst = this.windowNormalised(end);
                if abs(this.windowNormalised(end)) > 2*std(this.windowNormalised)
                    this.change = 1;
                end
                this.window = [this.window this.st];
            end

        end

        function setExtractorMethod(this, method)

            assert(isa(method, 'AbstractMethod'));
            this.extractorMethod = method;
            
        end
    end
end
