function [booleanVal, newRearImage] = extractionCriteriaFullfilled(obj, params, ...
    lastRearImage, currentFrame)
%extractionCriteriaFullfilled Check if criteria for extraction are fullfilled.
% Check if the image which is supposed to be cropped fullfills all the criteria:
% 1. occlusion value,
% 2. truncation value,
% 3. image size, and
% 4. comply with removal frequency for backside images.

% initialize values
booleanVal = false;
newRearImage = lastRearImage;

% select specified objects and fully visible vehicles
if (sum(strcmp(obj.vehicleType, params.objects)) == 1) && ...
        (obj.occlusion <= params.occlusion) &&  (obj.truncation <= params.truncation)
    
    % crop image only if it's 'large enough'
    if (obj.width >= params.minImgSize(2)) && (obj.height >= params.minImgSize(1))
        
        rearAngle = -1.57;
        rearBounds = [rearAngle - params.rearDeviation, rearAngle + params.rearDeviation];
        
        % if image is rear image then continue checking for last image from the rear
        if obj.angle > rearBounds(1) && obj.angle < rearBounds(2)
            
            % if last rear image was extracted at least x images before
            % (x=removalFrequency)
            if currentFrame - lastRearImage >= params.removalFrequency
                
                newRearImage = currentFrame;
                booleanVal = true;
            end
            
        % if image is not a rear image then there is no constraint for the extraction
        else
            booleanVal = true;
        end
    end
end
end