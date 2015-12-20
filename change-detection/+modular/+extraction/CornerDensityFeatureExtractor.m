classdef CornerDensityFeatureExtractor < modular.extraction.AbstractImageFeatureExtractor
    
    methods
        function features = getFeatures(this, bwEyeIm)
            
            if ~islogical(bwEyeIm)
                bwEyeIm = im2bw(bwEyeIm, 0.4);
            end
            
            [l,r] = this.getCorners(bwEyeIm);
            quadMeanL = this.getQuadMean(l.Location);
            quadMeanR = this.getQuadMean(r.Location);

            densityL = mean(pdist2(quadMeanL, l.Location));
            densityR = mean(pdist2(quadMeanR, r.Location));
            
            features = densityL + densityR;
        end
        
        function [leftEye, rightEye] = getCorners(~, cropped)
            
            corners = detectMinEigenFeatures(cropped);
            leftEye = corners(corners.Location(:,1) < size(cropped,2) / 2, :);
            rightEye = corners(corners.Location(:,1) > size(cropped,2) / 2, :);
            
        end
        
        function m = getQuadMean(~, points)
            nPoints = size(points,1);
            if nPoints == 0
                m = [eps eps];
            elseif nPoints == 1
                m = points;
            else
                m = sqrt(mean(points.^2));
            end
        end
    end

end

