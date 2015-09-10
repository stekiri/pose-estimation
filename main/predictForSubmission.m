function objects = predictForSubmission(poseModel, testImgLoc, testDetectLoc, ...
    i, featureParams, numClasses, predParams, varargin)

% load image
img = imread(fullfile(testImgLoc, sprintf('%06d.png', i)));

if nargin > 8
    % detect bounding boxes and calculate score
    bbs = acfDetect(img, varargin{1}); % varargin{1} contains detection model
    % save all detected objects as a structured object
    numObjects = size(bbs,1);
    for j=1:numObjects
        objects(j) = struct(...
            'type', 'Car',...
            'x1', bbs(j,1),...
            'y1', bbs(j,2),...
            'x2', bbs(j,1) + bbs(j,3),...
            'y2', bbs(j,2) + bbs(j,4),...
            'score', bbs(j,5));
    end
else
    % load precomputed bounding boxes
    objects = readLabels(testDetectLoc, i);
    numObjects = numel(objects);
end

for j=1:numObjects
    % extract the cropping information
    left = objects(j).x1;
    top = objects(j).y1;
    width = objects(j).x2 - objects(j).x1;
    height = objects(j).y2 - objects(j).y1;
    % crop image
    croppedImg = imcrop(img, [left top width height]);
    % compute feature vector
    testD.features = computeHSCForImage(...
        croppedImg, featureParams.D, featureParams.hscParams, ...
        featureParams.spamsParams);
    % estimate pose
    prediction = predictCombClassifRegrModel(...
        poseModel.Classif, poseModel.Regr, testD, numClasses, predParams);
    % save prediction in the structured object
    objects(j).alpha = prediction;
end
% set objects to empty array if there are no objects detected in image
if numObjects == 0
    objects = [];
end
end