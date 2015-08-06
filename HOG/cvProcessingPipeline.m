%% Initialization

workingFolder       = '/home/steffen/Dokumente/KITTI';
plotDirectory       = '/home/steffen/Dropbox/Aktuelles_Semester/Masterarbeit/Matlab_files/figures';
sourceLabelFolder   = fullfile(workingFolder, 'label_2');
experimentsFolder   = fullfile(workingFolder, 'experiments');

%% Step 0.1: Split into folds;

processParams.folds = 10;
foldsPath = fullfile(experimentsFolder, 'folds-split');

splitDataIntoFolds(processParams.folds, workingFolder, foldsPath)

%% Step 0.2: Split into drives

foldsDrivesPath = fullfile(experimentsFolder, 'folds-drives-split');

splitDataIntoDrives(workingFolder, foldsPath, foldsDrivesPath);

%% Step 1: Crop objects from dataset
% specify objects (cars, trucks, pedestrians), occlusion, truncation, threshold for image
% size (currently: 50)

difficulty          = 'easy';
% Difficulties as proposed on KITTI homepage
switch difficulty
    case 'easy'
        extractParams.occlusion = 0;
        extractParams.truncation = 0.15;
        extractParams.minImgSize = [40 0];
    case 'moderate'
        extractParams.occlusion = 1;
        extractParams.truncation = 0.3;
        extractParams.minImgSize = [25 0];
    case 'hard'
        extractParams.occlusion = 2;
        extractParams.truncation = 0.5;
        extractParams.minImgSize = [25 0];
end
extractParams.objects = {'Car'};
% 'gray' for conversion from rgb to gray image, otherwise 'rgb'
extractParams.mode = 'rgb';
extractParams.removalFrequency = 10;
extractParams.rearDeviation = 0.1;

currentFolder       = sprintf('cv_%s_%s_rf%d', difficulty, extractParams.mode, ...
    extractParams.removalFrequency);
cropPath            = fullfile(experimentsFolder, 'cropped_images');

cropObjectsFromImagesCVandRemoval(foldsDrivesPath, sourceLabelFolder, cropPath, ...
    currentFolder, extractParams);

%% Step 2: Preprocess images

% preprocParams.contrast = true;
% currentFolder   = sprintf('%s_prepro', difficulty);
% trainFolderIn  = fullfile(cropPath, difficulty, 'training');
% testFolderIn   = fullfile(cropPath, difficulty, 'test');
% trainFolderOut = fullfile(cropPath, currentFolder, 'training');
% testFolderOut = fullfile(cropPath, currentFolder, 'test');
%
% preprocessImages(trainFolderIn, trainFolderOut, preprocParams);
% preprocessImages(testFolderIn,  testFolderOut,  preprocParams);
%
% % copy txt files
% copyfile(fullfile(cropPath, difficulty, 'training.txt'), ...
%     fullfile(cropPath, currentFolder, 'training.txt'));
% copyfile(fullfile(cropPath, difficulty, 'test.txt'), ...
%     fullfile(cropPath, currentFolder, 'test.txt'));


%% Step 3: Sort objects into classes
% specify amount of classes + folders

processParams.classes   = 16;
classifPath             = fullfile(experimentsFolder, 'classified_images');
classifFolder           = sprintf('%s_cl%d', currentFolder, processParams.classes);

% perform sorting and write them into specified folders
sortImagesIntoClassesCV(cropPath, classifPath, currentFolder, classifFolder, processParams.classes);

%% Step 4.1: Copy all images to one folder (necessary for easier plotting)
helpString = 'allImages';
imgsInFolds = imageSet(fullfile(cropPath, currentFolder), 'recursive');
folderAllImages = fullfile(cropPath, sprintf('%s_%s', currentFolder, helpString));

writeImageSet(imgsInFolds, folderAllImages, false);

%% Step 4.2: Plot distribution of images in the sets

allImages = imageSet(folderAllImages);

distrParams.print        = false;
distrParams.saveLocation = fullfile(plotDirectory, 'images_per_class');
distrParams.plotName     = sprintf('imgPerClass_%s', helpString);
distrParams.difficulty   = difficulty;

[~, imgsPerClass] = plotDistributionOfImages(allImages, processParams.classes, distrParams);

%% Step 5: Equalize image sets
% % if #images in a class is lower resp. higher than threshold, mirroring resp. removal of
% % images is being performed
%
% switch difficulty
%     case 'easy'
%         eqParams.mirrorThreshold = 150; % set to zero to disable mirroring
%         eqParams.removeThreshold = 150; % set to inf to disable removal
%     case 'moderate'
%         eqParams.mirrorThreshold = 300;
%         eqParams.removeThreshold = 300;
%     case 'hard'
%         eqParams.mirrorThreshold = 500;
%         eqParams.removeThreshold = 500;
% end
%
% classifFolderOld = classifFolder;
% classifFolder    = sprintf('%s_mir%d', classifFolder, eqParams.mirrorThreshold);
%
% % copy folders before equalizing
% sourceFolder = fullfile(classifPath, classifFolderOld);
% destinFolder = fullfile(classifPath, classifFolder);
% copyfile(sourceFolder, destinFolder);
%
% % read image sets from new locations
% trainingSets = imageSet(fullfile(classifPath, classifFolder, 'training'), 'recursive');
% testSets     = imageSet(fullfile(classifPath, classifFolder, 'test'    ), 'recursive');
%
% % perform equalizing
% trainingSets = equalizeImageSet(trainingSets, eqParams);
% testSets     = equalizeImageSet(testSets,     eqParams);
%
% % continue with Step 6.1 and 6.2 or go directly to Step 7 (if generated image set should
% % not be saved on HDD)

%% Step 6.1: Write image sets in folder on HDD

% classifFolder = sprintf('%s_rem%d', classifFolder, eqParams.removeThreshold);
% trainImgFolder = fullfile(classifPath, classifFolder, 'training');
% testImgFolder  = fullfile(classifPath, classifFolder, 'test'    );
%
% writeImageSet(trainingSets, trainImgFolder);
% writeImageSet(testSets, testImgFolder);

%% Step 6.2: Read image sets

% trainingSets = imageSet(trainImgFolder, 'recursive');
% testSets     = imageSet(testImgFolder , 'recursive');

%% Step 7: Plot distribution of images in the sets [Optional]

% helpCurrConfig           = strsplit(trainingSets(1,1).ImageLocation{1,1}, '/');
%
% distrParams.print        = false;
% distrParams.saveLocation = fullfile(plotDirectory, 'images_per_class');
% distrParams.plotName     = sprintf('imgPerClass_%s', helpCurrConfig{1,end-3});
% distrParams.difficulty   = difficulty;
%
% plotDistributionOfImages(trainingSets, processParams.classes, distrParams);
% plotDistributionOfImages(testSets,     processParams.classes, distrParams);

%% Step 8: Set parameters
% for HOG

hogParams.amountHOGs      = [6 4];
hogParams.numBins         = 9;
hogParams.blockSize       = [2 2];
hogParams.blockOverlap    = ceil(hogParams.blockSize / 2);


% various HOG params
hogRange.amountHOGs = 2:2:10;
hogRange.numBins = 9;
hogRange.blockSize = 2;

m = 1;
hogParamList = [];
for i=1:length(hogRange.amountHOGs)
    for j=1:length(hogRange.amountHOGs)
        for k=1:length(hogRange.numBins)
            for l=1:length(hogRange.blockSize)
                
                hogParamList{1,m}.amountHOGs    = [hogRange.amountHOGs(i), hogRange.amountHOGs(j)];
                hogParamList{1,m}.numBins       = hogRange.numBins(k);
                hogParamList{1,m}.blockSize     = hogRange.blockSize(l);
                
                m = m+1;
            end
        end
    end
end

%% Step 9: Extract features

featExtractMethod = 'HSC'; % alternatives: 'HOG', 'HSC'

for i=1:processParams.folds
    currFoldName = sprintf('fold_%02d', i);
    imgSetOfCurrFold = imageSet(fullfile(classifPath, classifFolder, currFoldName), 'recursive');
    [currFold.features, currFold.exactLabels, currFold.classLabels, currFold.locations] = ...
        extractHOGFeaturesFromImageSet(imgSetOfCurrFold, hogParams);
    allFoldsData{1,i} = currFold;
end

% save('hogFeaturesCV_rf10.mat', 'allFoldsData')

%% Step 10: Cross-Validation
% train and predict

predParams = struct(...
    'model', 'combClassRegr',...
    'threshold', 0,...
    'library', 'libsvm',...   % alternatives: 'matlab', 'libsvm'
    'kernel', 'linear',...    % alternatives: 'linear, 'polynomial', 'rbf'
    'coding', 'onevsone',...  % alternatives: 'onevsall', 'onevsone', 'onevsone_custom'
    'weights', 'automaticWeights',...% alternatives: 'noWeights', 'automaticWeights'
    'weightFactor', 1,...
    'imgsPerClass', imgsPerClass,...
    'computeProbs', false,...
    'voting', 'majority',...  % alternatives: 'majority', 'probs', 'weighted_voting', 'inv_weighted_voting', 'specialized'
    'mode', 'reduced',...         % alternatives: 'reduced', 'all'
    'svmParameter', struct('C', '-', 'gamma', '-'),...
    'saveModel', false);      % save SVM model in result variable (can get large)

fullPredModelString = sprintf('%s%0.2f_%s_%s_%s_%s', predParams.model, ...
    predParams.threshold, predParams.library, predParams.kernel, predParams.coding, ...
    predParams.weights);

% parameter for grid
% gridParams.C = [0.25, 0.5, 1, 2, 4, 8];
% gridParams.gamma = [0.1, 0.25, 0.5, 0.75, 1];
gridParams.C = 0.5;
gridParams.gamma = '-';

processParams.backupLoc = '/home/steffen/Schreibtisch/backup';

allResults = performCrossValidation(allFoldsData, processParams, predParams, gridParams);

% save('hsc_results_noWeights.mat', 'allResults')
% save('hsc_results_automWeights.mat', 'allResults')
% save('hsc_results_automWeights10.mat', 'allResults')

%% 2nd layer svm to predict classes from probability estimates of first classifier
% % re-sort data
% 
% probData = cell(1,processParams.folds);
% for i=1:processParams.folds
%     probData{1,i} = struct('features',    {allResults{1,1}.cvResults{1,i}.probEstim}, ...
%         'exactLabels', {allFoldsData{1,i}.exactLabels}, ...
%         'classLabels', {allFoldsData{1,i}.classLabels}, ...
%         'locations',   {allFoldsData{1,i}.locations});
% end
% 
% predParams2 = struct(...
%     'model', 'combClassRegr',...
%     'threshold', 0,...
%     'library', 'libsvm',...   % alternatives: 'matlab', 'libsvm'
%     'kernel', 'linear',...    % alternatives: 'linear, 'polynomial', 'rbf'
%     'coding', 'onevsone',...  % alternatives: 'onevsall', 'onevsone', 'onevsone_custom'
%     'weights', 'noWeights',...% alternatives: 'noWeights', 'automaticWeights'
%     'computeProbs', false,...
%     'voting', 'majority',...  % alternatives: 'majority', 'probs', 'weighted_voting', 'inv_weighted_voting'
%     'mode', 'reduced');       % alternatives: 'reduced', 'all'
% 
% fullPredModelString = sprintf('%s%0.2f_%s_%s_%s_%s', predParams2.model, ...
%     predParams2.threshold, predParams2.library, predParams2.kernel, predParams2.coding, ...
%     predParams2.weights);
% 
% % parameter for grid
% gridParams2.C = 2^-6; %2.^[-3:2:4];
% % gridParams2.gamma = [0.1, 0.25, 0.5, 0.75, 1];
% % gridParams2.C = 0.5;
% gridParams2.gamma = '-';
% 
% results2ndLayer = performCrossValidation(probData, processParams, predParams2, gridParams2);

% save('allResultsIWV.mat', 'allResultsIWV')
% save('allResultsMVS.mat', 'allResultsMVS')
% save('allResults_linSVM_C05.mat', 'allResults')

%% Step 11: Print metrics and show plots

config = sprintf('%s_%s_%s', classifFolder, featExtractMethod, fullPredModelString);

specResult = allResults{1,1};

for cvNum=1:processParams.folds
    % print metrics
%     metrParams.description = specResult.cvResults{1,cvNum}.plotTitle;
%     printResultMetrics(specResult.cvResults{1,cvNum}.results, metrParams);
    
    
%     
%     
%     myHelperDisplayConfusionMatrix(specResult.cvResults{1,cvNum}.confMat, ...
%         processParams.classes, 'relative', false);
end

%% New Visualization

resultObject = hsc_autoW{1,1};
aggregatedResults = aggregateResults(resultObject, processParams.folds);

% Error plot
errParams.classes = processParams.classes;
errParams.print         = false;
errParams.plotName      = sprintf('error_%s', config);
errParams.saveLocation  = fullfile(plotDirectory, 'error_plots');
errParams.mode          = 'classes'; % alternatives: 'classes', 'difficulties'

errParams.description   = 'all folds';
createErrorPlot(aggregatedResults, errParams);

% Fold-wise analysis
% for cvNum = 1:processParams.folds
%     currentResults = allResults.cvResults{1,cvNum}.results;
%     % create error plots for every single fold
%     errParams.description = allResults.cvResults{1,cvNum}.plotTitle;
%     createErrorPlot(currentResults, errParams);
% end

% Class membership plot
clmemParams.singleFolds = false;
clmemParams.allFolds    = true;
createClassMembershipPlot(resultObject, processParams, clmemParams);

% Image examples plot
exParams.amountImages   = 36;
exParams.startingPoint  = 0;
% parameter for saving the plot
exParams.print          = false;
exParams.saveLocation   = fullfile(plotDirectory, 'image_examples');

exParams.mode           = 'worst'; % alternatives: 'worst', 'best'
exParams.description    = sprintf('%s examples - all folds', exParams.mode);
exParams.plotName       = sprintf('imgEx_%s_%sOffset%d', config, exParams.mode, ...
    exParams.startingPoint);
imgLocations = createImgExamplePlot(aggregatedResults, exParams);

% Image neighbors plot
neParams.neighbors      = 25;
for n=1:length(imgLocations)
    showNearestNeighbors(imgLocations{n}, aggregatedResults, featDistances, processParams, neParams);
end


%% RESULTS: average evaluation metric
%% matlab:
% 'no coding'           + threshold=0.25            --> 9.515118e-01 <--
% 'no coding'           + threshold=0.00            --> 9.506232e-01

% onevsall              + threshold=0.25            --> 9.427913e-01 <--
% onevsall              + threshold=0.00            --> 9.419267e-01
% onevsall              + threshold=3.14            --> 8.238562e-01

% onevsone/allpairs     + threshold=0.00            --> 9.506232e-01 <--
% denserandom           + threshold=0.00            --> 9.229620e-01
% onevsall              + threshold=0.00            --> 9.419267e-01
% ordinal               + threshold=0.00            --> 9.238851e-01
% sparserandom          + threshold=0.00            --> 9.412059e-01

%% libsvm:
% onevsall              + threshold=0.00            --> 9.419260e-01
% onevsone              + threshold=0.00            --> 9.513937e-01

% linear:
% C=0.00001                                         --> 5.909569e-01
% C=0.0001                                          --> 5.909569e-01
% C=0.001                                           --> 7.530877e-01
% C=0.01                                            --> 8.806629e-01
% C=0.1                                             --> 9.462340e-01
% C=1                                               --> 9.513937e-01 <--
% C=10                                              --> 9.498871e-01
% C=100                                             --> 9.510967e-01
% C=1,000                                           --> 9.508210e-01
% C=10,000                                          --> 9.508210e-01
% C=100,000                                         --> 9.508210e-01
% C=1,000,000                                       --> 9.508210e-01
% C=10,000,000                                      --> 9.508210e-01
% C=100,000,000                                     --> 9.508210e-01
% C=1,000,000,000                                   --> 9.508210e-01
% C=10,000,000,000                                  --> 9.508210e-01

% linear:
% C=0.03125                                         --> 9.203206e-01
% C=0.0625                                          --> 9.388586e-01
% C=0.125                                           --> 9.472833e-01
% C=0.25                                            --> 9.520026e-01
% C=0.5                                             --> 9.533351e-01 <--
% C=1                                               --> 9.513937e-01
% C=2                                               --> 9.522536e-01
% C=4                                               --> 9.512853e-01
% C=8                                               --> 9.500765e-01
% C=16                                              --> 9.496600e-01
% C=32                                              --> 9.493389e-01
% C=64                                              --> 9.507363e-01
% C=128                                             --> 9.508210e-01
% C=256                                             --> 9.508210e-01
% C=512                                             --> 9.508210e-01
% C=1024                                            --> 9.508210e-01

% rbf:
% see results file
