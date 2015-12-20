classdef Detector < handle
    %DETECTOR A blink detector with a modular, compartmentalised design.
    %   Detector.m defines a broad framework for a blink detector, with
    %   swappable implementations for change detection, feature extraction
    %   and eye extraction.
    
    properties
        eyeExtractor;
        featureExtractor;
        changeDetector;
        classifier;
        video
        videoFile
        st
        
        % Callbacks that can be assigned to do plotting, or additional
        % tasks unrelated to the core functionality. Unused if unset.
        step_callback = 0;
        setup_callback = 0;
        change_callback = 0;
    end
    
    methods
        function obj = Detector(videoFile)
            if isa(videoFile, 'VideoReader')
                obj.videoFile = videoFile.Name;
                obj.video = videoFile;
            else
                obj.videoFile = videoFile;
                obj.video = VideoReader(videoFile);
            end
            
            obj.reset();
        end
        
        function resetVideo(this)
            if ~this.video.hasFrame()
                this.video = VideoReader(this.videoFile);
            end
        end
        
        function reset(this)
            this.eyeExtractor = modular.extraction.CascadeEyeExtractor();
            this.featureExtractor = modular.extraction.CornerDensityFeatureExtractor();
            this.changeDetector = modular.cd.ControlChartChangeDetector(75);
            this.classifier = modular.classification.SVMClassifier();
            this.st = [];
            
            if isa(this.setup_callback, 'function_handle')
                this.setup_callback();
            end
        end
        
        function go(this)
            this.reset();
            this.resetVideo();
            figure; hold on;
            while this.video.hasFrame()
                this.processNextFrame();
            end
        end
        
        function blink = processNextFrame(this)
            nextFrame = rgb2gray(this.video.readFrame);
            
            % Extract eye image from frame
            eye = this.eyeExtractor.getEyeImage(nextFrame);
            
            if ~isempty(eye)
                % Extract features from eye image
                extracted = this.featureExtractor.getFeatures(eye);
                this.st = [this.st; extracted];
            else
                % If no eye is found, try not to rock the boat to minimise
                % false positives.
                this.st = [this.st; mean(this.st)];
                extracted = mean(this.st);
            end
            
            % Provide all the data to the plotting callback, if set.
            if isa(this.step_callback, 'function_handle')
                this.step_callback(nextFrame, eye, extracted, this.st);
            end

            this.changeDetector.append(extracted);
            if this.changeDetector.hasSufficientData()
                if this.changeDetector.change
                    % React to the change, providing the frame number for
                    % informational purposes.
                    if isa(this.change_callback, 'function_handle')
                        this.change_callback(numel(this.st));
                    end
                end
            end
            
            blink = this.changeDetector.change;
        end
    end
    
end

