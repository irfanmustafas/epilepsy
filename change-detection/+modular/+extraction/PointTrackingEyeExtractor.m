classdef PointTrackingEyeExtractor < modular.extraction.AbstractEyeExtractor
    %POINTTRACKINGEYEEXTRACTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ncoords = 0;
        previouscoords
        bboxcoords
        eye_bbox
        pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
        extractor = vision.CascadeObjectDetector('EyePairBig');
        tracking = false;
        
        extractionDimension = [150 300]
        
        % Mikkel's bounding box constants for decision making.
        previousBBox
        BBoxMaxDistance = 25 % 5
        BBoxMaxAreaDif = 100 % 40
        BBoxMinWidth = 30
        BBoxMinHeight = 15
        
        statusMessage = 'Uninitialized'
    end
    
    methods
        function eye = getEyeImage(this, frame)
            
            
            eye = [];
            
            % If RGB, convert to grayscale
            if size(frame,3) ~= 1
                frame = rgb2gray(frame);
            end
            
            if this.ncoords < 10
                this.statusMessage = 'Not found';
                bbox = step(this.extractor, frame);
                
                nEyes = size(bbox,1);
                
                if nEyes > 1 % We only want one pair of eyes.
                    [~,max_i] = max(bbox(:,3)); % take the widest.
                    bbox = bbox(max_i,:);
                elseif nEyes == 0
                    % No eyes in the image? Try using the previous bounding
                    % box.
                    bbox = this.previousBBox;
                end
                
                coords = detectMinEigenFeatures(frame, 'ROI', bbox);
                coords = coords.Location;
                this.ncoords = size(coords,1);
                this.bboxcoords = bbox2points(bbox);
                
                release(this.pointTracker);
                initialize(this.pointTracker, coords, frame);
                this.previouscoords = coords;
                this.previousBBox = bbox;
            end
            
            [nextCoords, isFound] = step(this.pointTracker, frame);
            visiblecoords = nextCoords(isFound, :);
            oldInliers = this.previouscoords(isFound, :);
            this.ncoords = size(visiblecoords,1);

            if this.ncoords >= 10
                this.statusMessage = 'Found';
                this.tracking = true;
                % Estimate the geometric transformation between the old coords
                % and the new coords and eliminate outliers
                [affine2d] = estimateGeometricTransform(...
                    oldInliers, visiblecoords, 'similarity', 'MaxDistance', 4);
                % Apply the transformation to the bounding box coords
                this.bboxcoords = transformPointsForward(affine2d, this.bboxcoords);
                this.eye_bbox = this.getEyeBB(this.tobbox(this.bboxcoords));
                eye = imcrop(frame, this.getRekt(this.bboxcoords));
                
                if this.tooSmallBBox(this.eye_bbox)
                    this.tracking = false;
                    this.ncoords = -1;
                else
                    % Resize to desired dimsension for consistency
                    eye = imresize(eye, this.extractionDimension);
                end
            end
            
            this.pointTracker.setPoints(visiblecoords);
            this.previouscoords = visiblecoords;
        end
        
        function bbox = tobbox(~, coords)
            xmin = min(coords(:,1));
            xmax = max(coords(:,1));
            ymin = min(coords(:,2));
            ymax = max(coords(:,2));
            bbox = [xmin xmax ymin ymax];
            
            % process case of 3D coords
            if size(coords, 2) > 2
                zmin = min(coords(:,3));
                zmax = max(coords(:,3));
                bbox = [xmin xmax ymin ymax zmin zmax];
            end
        end
        
        function rect = getRekt(this, coords)
            bbox = this.tobbox(coords);
            rect = [bbox(1), bbox(3), bbox(2) - bbox(1), bbox(4) - bbox(3)];
        end
        
        function bbox = getEyeBB(~, BBox)
            bbox = [];
            if ~isempty(BBox)
                % Take eyes from face
                BBeye(1, 2) = BBox(1, 2) + BBox(1, 4) / 5;
                % y = y + 20%
                BBeye(1, 4) = BBox(1, 4) - BBox(1, 4) / 5 ...
                    - BBox(1, 4) / 3 - BBox(1, 4) / 10;
                % h = h - 20% - 33%
                BBeye(1, 1) = BBox(1, 1) + BBox(1, 3) / 7;
                BBeye(1, 3) = BBox(1, 3) - BBox(1, 3) / 5;
                
                bbox = BBeye;
            end
        end
        
        function tooDifferent = tooDifferentBBox(this, BBox2)
            % compared with vs.previousBBox
            tooDifferent = false;
            BBox1 = this.previousBBox;
            distance = pdist([BBox1(1 : 2); BBox2(1 : 2)]);
            areaDif = abs(prod(BBox1(3 : 4)) - prod(BBox2(3 : 4)));
            if (distance > this.BBoxMaxDistance) || ...
                    (areaDif > this.BBoxMaxAreaDif)
                tooDifferent = true;
            end
        end
        
        function tooSmall = tooSmallBBox(this, BBox2)
            % compared with vs.previousBBox
            tooSmall = false;
            width = BBox2(3);
            height = BBox2(4);
            if (width < this.BBoxMinWidth) || (height < this.BBoxMinHeight)
                tooSmall = true;
                disp([width height ])
            end
        end
        
        % Destructor method
        function delete(this)
            release(this.extractor);
            release(this.pointTracker);
        end
        
    end
    
    
end

