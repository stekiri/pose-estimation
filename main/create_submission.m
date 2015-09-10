%% Create submission results with precomputed detection results
% Process flow:
% 1. Load parameters
% 2. Train pose estimation model
% 3. Load detection results (bounding boxes + score)
% 4. Crop found images and estimate pose
% 5. Write back to txt-files

%% Parameters
% load global params
% glob_params

% other params
testLoc         = '/home/steffen/Dokumente/KITTI/testing';
testImgLoc      = fullfile(testLoc, 'image_2');
testDetectLoc   = fullfile(testLoc, 'detection_boxes');
testSaveLoc    = fullfile(testLoc, 'labels');

%% Train pose estimation on all training images
% load features
% load('HSC_moderate_rf10_dict36.mat')
% concatenate the data from all folds
trainD = mergeData(allFoldsData);
% learn model
[model.Classif, model.Regr] = trainCombClassifRegrModel(trainD, ...
    processParams.classes, predParams);

%% [OPTIONAL] Load detection model

load('Detectors_mail.mat')

%% test pipeline
numImages = 7518;
% execute detection & pose estimation for all images
fprintf('Perform detection & pose estimation for all test images ... ');
tic;
parfor i=0:(numImages-1)
    % if detection model shall be used, execute function with 'dets' as optional argument
    objects = predictForSubmission(model, testImgLoc, testDetectLoc, i, ...
        featureParams, processParams.classes, predParams);
    
    if isempty(objects)
        % write empty file when there are no detected objects in the image
        fid = fopen(sprintf('%s/%06d.txt', testSaveLoc , i),'w');
        fclose(fid);
    else
        % write objects to file
        writeLabels(objects, testSaveLoc, i);
    end
end
fprintf('DONE!\n')
t = toc;
fprintf('computation time: %0.2f hrs\n', t/60/60);