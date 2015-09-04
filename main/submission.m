%% Parameters
% load global params
glob_params

% other params
testLoc         = '/home/steffen/Dokumente/KITTI/testing';
testSetLoc      = fullfile(testLoc, 'image_2');
testLabelLoc    = fullfile(testLoc, 'labels');

%% Load detection model

load('Detectors_mail.mat')

%% Train pose estimation on all training images
% load features
featureFileName = sprintf('hsc_features_dictLength_%d.mat', featureParams.spamsParams.K);
load(featureFileName)
% concatenate the data from all folds
trainD = mergeData(allFoldsData);
% learn model
[modelC, modelR] = trainCombClassifRegrModel(trainD, processParams.classes, predParams);

%% test pipeline
% load test images
testSet = imageSet(testSetLoc, 'recursive');

% execute detection & pose estimation for all images
fprintf('Perform detection & pose estimation for all test images ... ');
tic;
reverseStr = '';
for i=1:testSet.Count
    % load image
    img = imread(testSet.ImageLocation{1,i});
    % detect bounding boxes + ?
    bbs = acfDetect(img,dets);
    % display bounding boxes
%     imshow(img); bbApply('draw',bbs);
    
    % crop & estimate pose for all found objects
    numObjects = size(bbs,1);
    % remove previous variable
    clear testObjects;
    
    for j=1:numObjects
        % crop image
        croppedImg = imcrop(img, bbs(j,1:4));
        % compute feature vector
        testD.features = computeHSCForImage(...
            croppedImg, featureParams.D, featureParams.hscParams, ...
            featureParams.spamsParams);
        % estimate pose
        prediction = testCombClassifRegrModel(...
            modelC, modelR, testD, processParams.classes, predParams);
        
        % write relevant information into txt file
        testObjects(j) = struct(...
            'type', 'Car',...
            'x1', bbs(j,1),...
            'y1', bbs(j,2),...
            'x2', bbs(j,1) + bbs(j,3),...
            'y2', bbs(j,2) + bbs(j,4),...
            'alpha', prediction,...
            'score', bbs(j,5));
        
    end
    
    if numObjects == 0
        % write empty file
        fid = fopen(sprintf('%s/%06d.txt', testLabelLoc , i-1),'w');
        fclose(fid);
    else
        % write objects to file
        writeLabels(testObjects, testLabelLoc, i-1);
    end
    
    % display progress
    msg = sprintf('%d/%d', i, testSet.Count);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
fprintf('DONE!\n')
t = toc;
fprintf('computation time: %0.2f hrs\n', t/60/60);