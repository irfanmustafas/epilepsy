classdef CornersMethod < AbstractMethod

    methods
        function st = extract(this, bwEyeIm)
            [l,r] = this.getCorners(bwEyeIm);
            quadMeanL = sqrt(mean(l.Location.^2));
            quadMeanR = sqrt(mean(r.Location.^2));
            
            densityL = mean(pdist2(quadMeanL, l.Location));
            densityR = mean(pdist2(quadMeanR, r.Location));
            
            st = densityL + densityR;
        end
        
        function [leftEye, rightEye] = getCorners(~, cropped)
            
            corners = detectMinEigenFeatures(cropped);
            leftEye = corners(find(corners.Location(:,1) < size(cropped,2) / 2), :);
            rightEye = corners(find(corners.Location(:,1) > size(cropped,2) / 2), :);
            
        end
    end
    
end

