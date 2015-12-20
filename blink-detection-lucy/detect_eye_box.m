function [BBox, xyPoints] = detect_eye_box(im, PARAM)

global detector pointTracker flag_lost

if nargin == 1
    proportion_face = 0.5;
else
    proportion_face = PARAM.proportion_face;
end

BBox = [];
xyPoints = [];

BBoxAll = detector.step(im);
nE = size(BBoxAll, 1);
if nE == 0 % no face ---------------------------
    flag_lost = true; % no face in the image
else
    % eyes -------------------------------------
    if nE > 1 % there should be only one face
        [~,indexmax] = max(BBoxAll(:, 3)); % take the widest
        BBox = BBoxAll(indexmax, :);
    else
        BBox = BBoxAll;
    end
    
    if BBox(3) < proportion_face*size(im,2) % not a face
        flag_lost = true; % no face in the image
    else
        % MAY NEED ADJUSTMENT
        % Take eyes from face --------------------------------------------
        BBeye(2) = BBox(1,2) + 0.25*BBox(1,4);
        BBeye(4) = 0.25*BBox(1, 4);
        BBeye(1) = BBox(1,1) + 0.15*BBox(1,3);
        BBeye(3) = 0.7*BBox(1,3);
        BBox = round(BBeye); % -------------------------------------------
        
        % Find corner points inside the detected region.
        points = detectMinEigenFeatures(im,'ROI', BBox);
        
        % Re-initialize the point tracker.
        xyPoints = points.Location;
        
        release(pointTracker);
        initialize(pointTracker, xyPoints, im);
    end
end