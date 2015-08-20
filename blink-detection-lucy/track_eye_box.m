function [outer_rect, xyPoints, bboxPoints] = ...
    track_eye_box(im, oldPoints, BBox, PARAM)

global pointTracker flag_lost

if nargin == 3
    threshold_matching_points = 0.01*BBox(3)*BBox(4);
    box_distance_threshold = 200; % threshold for squared distance
    % between the original box and the transformed box
else
    threshold_matching_points = PARAM.threshold_matching_points;
    box_distance_threshold = PARAM.box_distance_threshold;
end

outer_rect = BBox;

[xyPoints, isFound] = step(pointTracker,im);
visiblePoints = xyPoints(isFound, :);
oldInliers = oldPoints(isFound, :);
    
bboxPoints = bbox2points(BBox); % original eye-box corner points

if size(visiblePoints,1) > threshold_matching_points
    bboxPoints_o = bboxPoints;
    xform = estimateGeometricTransform(oldInliers, visiblePoints, ...
        'similarity', 'MaxDistance', 4);
    % Apply the transformation to the bounding box
    bboxPoints = transformPointsForward(xform,bboxPoints_o);
    
    % The new box shouldn't be too far away from the original
    % bounding box. If it is, we might have lost tracking
    
    sed = sum((bboxPoints_o(:) - bboxPoints(:)).^2);
    % (squared Euclidean distance)
    if sed > box_distance_threshold
        % threshold for squared distance exceeded
        flag_lost = true;
    else
        % Find the middle and then centre the eye Box
        centre_new = mean(bboxPoints);
        outer_rect = [centre_new(1) - BBox(3)/2,...
            centre_new(2) - BBox(4)/2,BBox(3:4)];
    end
    
else
    flag_lost = true; % tracking lost due to not enough matching points
end
