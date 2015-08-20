classdef VideoSurveillance < handle
    properties
        
        videoName % path and name of the video to be used
        video % VideoReader object
        detector % vision.CascadeObjectDetector() used for face detection
        % mean
        
                
        videoPlayer         % video player to watch the video
        videoPlayerPosition = [100 100 [260 130]+30] 
        % configuration for the video player        
        videoCropPosition = [320 150 260 130]   % Position to crop the video (pillow area)        
        % videoCropPosition = [1 1 500 500]   % Position to crop the video (pillow area)

          
        previousFrames      % Previous frames used to compute the difference with the current one
        nPreviousFrames = 10  % Number of previous frames to use for the mean
        pointTracker        % Tracker for the points once a face has been detected
        numPts, oldPoints   % Points for tracking
        bboxPoints          % BBox for tracking
        
        blinkEstimation % blinking vector with the whole plot of the video
        nBlinkEstimation = 2000 % number of frames to consider
        nConsecutive
        blinking % eyes closed or open
        blinkingCount % total numberof blinks
        isLost % whether the previousFrames are valid or not (focus is
        % lost, new frames are needed to estimate the mean again)
        blinkThreshold = 0.2 % mean + blinkThreshold * std to detect blink
        blinkEstimationWindow % blink estimation window used to compute the
        % threshold
        nFramesBlinkDetection = 100 % number of frames used to compute the
        % mean and std of the difference to detect blinking
        thresholdsList % list of threshold used for blinkEstimation
        differenceThreshold = 15 % minimum pixel intensity difference for
        % accepting movement
        initialThreshold = 5 % initial threshold value for
        % blinkEstimationWindow
        minThreshold = 5 % minimum threshold to consider
        outofNormality = 60 % number of pixels to assume head/body movement
        % rather than blinking
        
        state % 1 = All moving, 2 = Face not detected, 3 = Face moving,
        % 0 = Tracking - blink detection!
        timer % 10 secs if 1, 1 sec if 2 or 3 and real time (0) if 0.
        previousStates % save last states
        nPreviousStates = 300
        
        previousBBox
        BBoxMaxDistance = 25 % 5
        BBoxMaxAreaDif = 100 % 40
        BBoxMinWidth = 30
        BBoxMinHeight = 15
        
        differenceThresholdGlobal = 10000
        %1000 % number of pixels that should be different to consider "all
        % moving" state
        grayDifferenceThresholdGlobal = 10 % pixel difference to be
        % considered enough for accepting movement
        
        previouosWholeFrame % previous frames used to compute the global
        % difference with the current one
        
        useVideoPlayer = false
    end
    
    methods
        function vs = VideoSurveillance()
            vs.previousFrames = matrixQueue(vs.nPreviousFrames);
            vs.blinkEstimation = queue(vs.nBlinkEstimation);
            vs.nConsecutive = 0;
            vs.blinking = false;
            vs.blinkingCount = 0;
            vs.isLost = false;
            vs.thresholdsList = queue(vs.nBlinkEstimation);
            vs.blinkEstimationWindow = queue(vs.nFramesBlinkDetection);
            vs.blinkEstimationWindow.initialize(vs.initialThreshold);
            vs.state = 0;
            vs.timer = 0;
            vs.previousStates = queue(vs.nPreviousStates);
            vs.previouosWholeFrame = matrixQueue(vs.nPreviousFrames);
            vs.numPts = 0;
        end
        
        function initialize(vs, videoName)
            vs.videoName = videoName;
            vs.video = VideoReader(vs.videoName);
            % It is really a face detector, not detecting eyes in new
            % videos...
            vs.detector = vision.CascadeObjectDetector(); % 'EyePairBig'
            % Create the point tracker object.
            vs.pointTracker = ...
                vision.PointTracker('MaxBidirectionalError', 2);
            
            % Create the video player object.
            vs.videoPlayer = vision.VideoPlayer('Position', ...
                vs.videoPlayerPosition);
            % ('Position', [100 100 [frameSize(2), frameSize(1)]+30]);
            vs.useVideoPlayer = true; % no preview
            
            frame = vs.video.readFrame();
            frame = imcrop(frame, vs.videoCropPosition);
            frame = double(rgb2gray(frame));
            vs.previouosWholeFrame.push(frame);
            
        end
        
        function initializeForWebcam(vs, firstFrame)
            vs.detector = vision.CascadeObjectDetector(); % 'EyePairBig'
            % Create the point tracker object.
            vs.pointTracker = ...
                vision.PointTracker('MaxBidirectionalError', 2);
            
            frame = imcrop(firstFrame, vs.videoCropPosition);
            frame = double(rgb2gray(frame));
            vs.previouosWholeFrame.push(frame);
            
            % Create the video player object.
            vs.videoPlayer = vision.VideoPlayer('Position', ...
                vs.videoPlayerPosition);
            % ('Position', [100 100 [frameSize(2), frameSize(1)]+30]);
            vs.useVideoPlayer = true;
        end
        
        function run(vs)
            runLoop = true;
            frameCount = 1;
            while runLoop && vs.video.hasFrame()
                % Get the next frame.
                currentFrame = vs.video.readFrame(); %snapshot(cam);
                frameCount = frameCount + 1;
                
                vs.doLoop(currentFrame);
                
                % Check whether the video player window has been closed.
                runLoop = isOpen(vs.videoPlayer);
            end
            release(vs.videoPlayer);
            release(vs.pointTracker);
            release(vs.detector);
        end
        
        function doLoop(vs, currentFrame)
            % Get the next frame.
            currentFrame = imcrop(currentFrame, vs.videoCropPosition);
            % [xmin ymin width height]
            currentFrame = rgb2gray(currentFrame);
            
            currentOriginalFrame = double(currentFrame);
            if vs.timer == 0
                if (sum(sum(abs(mean(vs.previouosWholeFrame.elems, 3)...
                        - currentOriginalFrame) > ...
                        vs.grayDifferenceThresholdGlobal)) < ...
                        vs.differenceThresholdGlobal)
                    [currentFrame] = vs.processFrame(currentFrame);
                    
                    if vs.useVideoPlayer && vs.blinking
                        currentFrame = insertText(currentFrame,...
                            [70 30],'BLINKING!!',...
                            'AnchorPoint','LeftBottom');
                    end
                else
                    vs.state = 1;
                    vs.timer = 30; % CAMBIAR 10 * 30; 
                    % 10 seconds considering frame rate of 30fps
                end
            elseif vs.useVideoPlayer
                currentFrame = insertText(currentFrame,[30 30], ...
                    ['Waiting for a stable image... state = ' ...
                    num2str(vs.state)],'AnchorPoint','LeftBottom');
            end
            
            vs.previouosWholeFrame.push(currentOriginalFrame);
            
            if (vs.useVideoPlayer)
                % Display the annotated video frame using the video 
                % player object.
                if (size(currentFrame, 3) == 1)
                    currentFrame = repmat(currentFrame, 1, 1, 3);
                end
                step(vs.videoPlayer, currentFrame);
            end
            
            if (vs.timer > 0)
                vs.timer = vs.timer - 1;
            end
            vs.previousStates.push(vs.state);
            
        end
        
        function [frameAnnotated] = processFrame(vs, frame)
            frameAnnotated = frame;
            %             frame = rgb2gray(frame);
            if vs.numPts < 10
                BBoxAll = vs.detector.step(frame);
                
                nE = size(BBoxAll, 1);
                if nE > 1 % there should be only one pair of eyes
                    [~,indexmax] = max(BBoxAll(:, 3)); % take the widest
                    BBox = BBoxAll(indexmax, :);
                else
                    BBox = BBoxAll;
                end
                
                if ~isempty(BBox)
                    % Take eyes from face
                    BBeye(1, 2) = BBox(1, 2) + BBox(1, 4) / 5; 
                    % y = y + 20%
                    BBeye(1, 4) = BBox(1, 4) - BBox(1, 4) / 5 ...
                        - BBox(1, 4) / 3 - BBox(1, 4) / 10; 
                    % h = h - 20% - 33%
                    BBeye(1, 1) = BBox(1, 1) + BBox(1, 3) / 7;
                    BBeye(1, 3) = BBox(1, 3) - BBox(1, 3) / 5;
                    
                    vs.previousBBox = BBeye(1, :);
                    
                    % Find corner points inside the detected region.
                    points = detectMinEigenFeatures(frame,...
                        'ROI', BBeye(1, :));
                    
                    % Re-initialize the point tracker.
                    xyPoints = points.Location;
                    vs.numPts = size(xyPoints,1);
                    release(vs.pointTracker);
                    initialize(vs.pointTracker, xyPoints, frame);
                    
                    % Save a copy of the points.
                    vs.oldPoints = xyPoints;
                    
                    % Convert the rectangle represented as [x, y, w, h] 
                    % into an M-by-2 matrix of [x,y] coordinates of the 
                    % four corners. This is needed to be able to transform 
                    % the bounding box to display the orientation of the 
                    % face.
                    
                    vs.bboxPoints = bbox2points(BBeye(1, :));
                    eyeImage = imcrop(frame, BBeye(1, :));
                    
                    % Convert the box corners into the 
                    % [x1 y1 x2 y2 x3 y3 x4 y4]
                    % format required by insertShape.
                    bboxPolygon = reshape(vs.bboxPoints', 1, []);
                    
                    % Display a bounding box around the detected face.
                    frameAnnotated = insertShape(frameAnnotated, ...
                        'Polygon', bboxPolygon, 'LineWidth', 3);
                    
                    vs.previousFrames.clear();
                    vs.previousFrames.push(double(eyeImage));
                    vs.state = 0;
                else
                    vs.previousFrames.clear();
                    if (vs.blinking)
                        vs.blinkingCount = vs.blinkingCount - 1;
                        vs.blinking = false;
                    end
                    vs.nConsecutive = 0;
                    vs.blinkEstimationWindow.initialize(...
                        vs.initialThreshold);
                    vs.isLost = true;
                    vs.state = 2;
                    vs.timer = 30;
                end
                
            else
                % Tracking mode.
                [xyPoints, isFound] = step(vs.pointTracker, frame);
                visiblePoints = xyPoints(isFound, :);
                oldInliers = vs.oldPoints(isFound, :);
                
                vs.numPts = size(visiblePoints, 1);
                
                if vs.numPts >= 10
                    % Estimate the geometric transformation between the 
                    % old points and the new points.
                    [xform, ~, visiblePoints] = ...
                        estimateGeometricTransform(...
                        oldInliers, visiblePoints, ...
                        'similarity', 'MaxDistance', 4);
                    
                    % Apply the transformation to the bounding box.
                    vs.bboxPoints = transformPointsForward(xform, ...
                        vs.bboxPoints);
                    
                    xmin = min(vs.bboxPoints(:,1)) - 1;
                    ymin = min(vs.bboxPoints(:,2)) - 1;
                    xmax = max(vs.bboxPoints(:,1)) + 1;
                    ymax = max(vs.bboxPoints(:,2)) + 1;
                    % define outer rect:
                    outer_rect=[xmin ymin xmax-xmin ymax-ymin];
                    eyeImage = imcrop(frame,outer_rect);
                    
                    bboxPolygon = reshape(vs.bboxPoints', 1, []);
                    
                    
                    
                    
                    % Display a bounding box around the face being tracked.
                    frameAnnotated = insertShape(frameAnnotated, ...
                        'Polygon', bboxPolygon, 'LineWidth', 3);
                    
                    
                    % Test whether the position or size of the face differs
                    % too much from the previous one, if that is the case,
                    % then isLost = true and do not detectBlinking
                    
                    % Also if the size is too small, avoid doing nothing
                    
                    if (vs.tooDifferentBBox(outer_rect)) 
                        % compared with vs.previousBBox
                        vs.state = 3; % Face moving!!
                        vs.timer = 30; % 1 second
                    elseif (vs.tooSmallBBox(outer_rect))
                        vs.isLost = true;
                        vs.numPts = -1;
                        vs.state = 2; % Face not detected!!
                        vs.timer = 30; % 1 second
                    else
                        vs.state = 0;
                        if (~vs.previousFrames.empty())
                            eyeImage = imresize(eyeImage, ...
                                vs.previousFrames.getDimension());
                        end
                        vs.previousFrames.push(double(eyeImage));
                        
                        vs.detectBlinkingFromEyeImage(eyeImage, frame);
                        if (vs.isLost)
                            vs.numPts = -1;
                        end
                        
                    end
                    % Reset the points.
                    vs.oldPoints = visiblePoints;
                    setPoints(vs.pointTracker, vs.oldPoints);
                    vs.previousBBox = outer_rect;
                end
                
            end
            
        end
        
        function tooDifferent = tooDifferentBBox(vs, BBox2) 
            % compared with vs.previousBBox
            tooDifferent = false;
            BBox1 = vs.previousBBox;
            distance = pdist([BBox1(1 : 2); BBox2(1 : 2)]);
            areaDif = abs(prod(BBox1(3 : 4)) - prod(BBox2(3 : 4)));
            if (distance > vs.BBoxMaxDistance) || ...
                    (areaDif > vs.BBoxMaxAreaDif)
                tooDifferent = true;
            end
        end
        
        function tooSmall = tooSmallBBox(vs, BBox2) 
            % compared with vs.previousBBox
            tooSmall = false;
            width = BBox2(3);
            height = BBox2(4);
            if (width < vs.BBoxMinWidth) || (height < vs.BBoxMinHeight)
                tooSmall = true;
                disp([width height ])
            end
        end
        
        function detectBlinkingFromEyeImage(vs, image, ~)
            vs.isLost = false;
            referenceImage = mean(vs.previousFrames.elems, 3);
            differenceImage =  uint8(abs(double(image) - referenceImage));
            
            if (vs.previousFrames.isFull()) % enough frames to proceed
                % difference = sum(double(differenceImage(:)).^2);
                differenceImage = double(differenceImage(:)).^2;
                difference = sum(differenceImage > ...
                    vs.differenceThreshold^2);
                
                vs.blinkEstimation.push(difference);
                vs.blinkEstimationWindow.push(difference);
                
                bEstW = vs.blinkEstimationWindow.getElements();
                threshold = mean(bEstW) + vs.blinkThreshold * std(bEstW);
                % 0.2 very good 0.8 also
                threshold = max(threshold, vs.minThreshold);
                vs.thresholdsList.push(threshold);
                
                if (difference > vs.outofNormality)
                    disp('Cannot detect blinking in this situation');
                    if (vs.blinking)
                        vs.blinkingCount = vs.blinkingCount - 1;
                        vs.blinking = false;
                    end
                    vs.previousFrames.clear();
                    vs.nConsecutive = 0;
                    vs.blinkEstimationWindow.initialize(...
                        vs.initialThreshold);
                    
                elseif (difference > threshold)
                    vs.nConsecutive = vs.nConsecutive + 1;
                    vs.previousFrames.removeLast();
                    
                    if (vs.nConsecutive > 60)
                        vs.previousFrames.clear();
                        disp('Ouch! It wasn''t a blink!');
                        vs.blinking = false;
                        vs.blinkingCount = vs.blinkingCount - 1;
                        vs.nConsecutive = 0;
                        % vs.blinkEstimation = [];
                        vs.blinkEstimationWindow.initialize(...
                            vs.initialThreshold);
                        % vs.thresholdsList = [];
                        % vs.isLost = true;
                    elseif (~vs.blinking)
                        vs.blinkingCount = vs.blinkingCount + 1;
                        disp(['Blinking starts! ', ...
                            num2str(vs.blinkingCount)]);
                        vs.blinking = true;
                    end
                elseif (difference < ...
                        mean(vs.blinkEstimationWindow.getElements()))
                    vs.nConsecutive = 0;
                    if (vs.blinking)
                        disp(['Blinking ends!!! ', ...
                            num2str(vs.blinkingCount)]);
                    end
                    vs.blinking = false;
                end
            end
            
        end
        function nBlinking = getAndSetBlinking(vs)
            if (vs.blinking)
                nBlinking = vs.blinkingCount - 1;
            else
                nBlinking = vs.blinkingCount;
            end
            vs.blinkingCount = vs.blinkingCount - nBlinking;
        end
        
        function states = getAndSetPreviousStates(vs)
            states = vs.previousStates.getElements();
            vs.previousStates.clear();
        end
    end
end