%% Initialization


workingFolder       = '/home/steffen/Dokumente/KITTI';
plotDirectory       = '/home/steffen/Dropbox/Aktuelles_Semester/Masterarbeit/Matlab_files/figures';
sourceImgFolder     = fullfile(workingFolder, 'drive_split');
sourceLabelFolder   = fullfile(workingFolder, 'label_2');
experimentsFolder   = fullfile(workingFolder, 'experiments');

%% Step 0: Split into training and test data set

% -- See "split_train_and_test.m"

%% Step 1: Crop objects from dataset
% specify objects (cars, trucks, pedestrians), occlusion, truncation, threshold for image
% size (currently: 50)

difficulty          = 'easy';
% 'gray' for conversion from rgb to gray image, otherwise 'rgb'
mode = 'rgb';
currentFolder       = sprintf('%s_%s', difficulty, mode);
cropPath            = fullfile(experimentsFolder, 'cropped_images');

% Difficulties as proposed on KITTI homepage
% {{[vehicle_type]}, [occlusion], [truncation], [minimal_image_size (H W)]}
switch difficulty
    case 'easy'
        extractParams = {{'Car'}, 0, 0.15, [40 0]};
    case 'moderate'
        extractParams = {{'Car'}, 1, 0.30, [25 0]};
    case 'hard'
        extractParams = {{'Car'}, 2, 0.50, [25 0]};
end
extractParams = [extractParams, mode];

cropObjectsFromImages(sourceImgFolder, sourceLabelFolder, cropPath, currentFolder, ...
    extractParams);

%% Step 2: Preprocess images

preprocParams.contrast = true;
currentFolder   = sprintf('%s_prepro', difficulty);
trainFolderIn  = fullfile(cropPath, difficulty, 'training');
testFolderIn   = fullfile(cropPath, difficulty, 'test');
trainFolderOut = fullfile(cropPath, currentFolder, 'training');
testFolderOut = fullfile(cropPath, currentFolder, 'test');

preprocessImages(trainFolderIn, trainFolderOut, preprocParams);
preprocessImages(testFolderIn,  testFolderOut,  preprocParams);

% copy txt files
copyfile(fullfile(cropPath, difficulty, 'training.txt'), ...
    fullfile(cropPath, currentFolder, 'training.txt'));
copyfile(fullfile(cropPath, difficulty, 'test.txt'), ...
    fullfile(cropPath, currentFolder, 'test.txt'));


%% Step 3: Sort objects into classes
% specify amount of classes + folders

amountClasses       = 16;
classifPath         = fullfile(experimentsFolder, 'classified_images');
classifFolder       = sprintf('%s_cl%d', currentFolder, amountClasses);

% perform sorting and write them into specified folders
sortImagesIntoClasses(cropPath, classifPath, currentFolder, classifFolder, amountClasses);

%% Step 4: Initial reading of image sets

trainingSets = imageSet(fullfile(classifPath, classifFolder, 'training'), 'recursive');
testSets     = imageSet(fullfile(classifPath, classifFolder, 'test'    ), 'recursive');

% if equalizing of image sets is desired continue with Step 5, otherwise continue with
% Step 7

%% Step 5: Equalize image sets
% if #images in a class is lower resp. higher than threshold, mirroring resp. removal of
% images is being performed

switch difficulty
    case 'easy'
        eqParams.mirrorThreshold = 150; % set to zero to disable mirroring
        eqParams.removeThreshold = 150; % set to inf to disable removal
    case 'moderate'
        eqParams.mirrorThreshold = 300;
        eqParams.removeThreshold = 300;
    case 'hard'
        eqParams.mirrorThreshold = 500;
        eqParams.removeThreshold = 500;
end

classifFolderOld = classifFolder;
classifFolder    = sprintf('%s_mir%d', classifFolder, eqParams.mirrorThreshold);

% copy folders before equalizing
sourceFolder = fullfile(classifPath, classifFolderOld);
destinFolder = fullfile(classifPath, classifFolder);
copyfile(sourceFolder, destinFolder);

% read image sets from new locations
trainingSets = imageSet(fullfile(classifPath, classifFolder, 'training'), 'recursive');
testSets     = imageSet(fullfile(classifPath, classifFolder, 'test'    ), 'recursive');

% perform equalizing
trainingSets = equalizeImageSet(trainingSets, eqParams);
testSets     = equalizeImageSet(testSets,     eqParams);

% continue with Step 6.1 and 6.2 or go directly to Step 7 (if generated image set should
% not be saved on HDD)

%% Step 6.1: Write image sets in folder on HDD

classifFolder = sprintf('%s_rem%d', classifFolder, eqParams.removeThreshold);
trainImgFolder = fullfile(classifPath, classifFolder, 'training');
testImgFolder  = fullfile(classifPath, classifFolder, 'test'    );

writeImageSet(trainingSets, trainImgFolder, true);
writeImageSet(testSets, testImgFolder, true);

%% Step 6.2: Read image sets

trainingSets = imageSet(trainImgFolder, 'recursive');
testSets     = imageSet(testImgFolder , 'recursive');

%% Step 7: Plot distribution of images in the sets [Optional]

helpCurrConfig           = strsplit(trainingSets(1,1).ImageLocation{1,1}, '/');

distrParams.print        = false;
distrParams.saveLocation = fullfile(plotDirectory, 'images_per_class');
distrParams.plotName     = sprintf('imgPerClass_%s', helpCurrConfig{1,end-3});
distrParams.difficulty   = difficulty;

plotDistributionOfImages(trainingSets, amountClasses, distrParams);
plotDistributionOfImages(testSets,     amountClasses, distrParams);

%% Step 8: Set parameters
% for HOG
hogParams.amountHOGs      = [6 4];
hogParams.numBins         = 9;
hogParams.blockSize       = [2 2];
hogParams.blockOverlap    = ceil(hogParams.blockSize / 2);

%% Step 9: Extract features

% --- TODO: training with mirrored+removed dataset, testing with original dataset

featExtractMethod = 'HOG';

switch featExtractMethod
    case 'HOG'
        [trainD.features, trainD.exactLabels, trainD.classLabels, trainD.locations] = ...
            extractHOGFeaturesFromImageSet(trainingSets, hogParams);
        
        [testD.features, testD.exactLabels, testD.classLabels, testD.locations] = ...
            extractHOGFeaturesFromImageSet(testSets, hogParams);
    % --- TODO: implement other feature extraction methods
end

%% Step 10: Perform training and prediction

predictiveModel = 'combClassRegr';

switch predictiveModel
    case 'combClassRegr'
        votingThresh        = 0.25;
        predParams.learner  = templateSVM('KernelFunction','linear');
        predParams.codingCl = 'onevsone';
        predParams.library  = 'matlab';
        
        [results, plotTitle, confMat] = combinedClassifRegrApproach(trainD, testD, ...
            amountClasses, votingThresh, predParams);
        predModelWithParam = sprintf('%s%0.2f', predictiveModel, votingThresh);
    % --- TODO: implement other ml methods
end

%% Step 11: Print metrics and show plots

config = sprintf('%s_%s_%s', classifFolder, featExtractMethod, predModelWithParam);

% print metrics
metrParams.description = plotTitle;
printResultMetrics(results, metrParams);

% Error plot
helpVec = cell2mat(results(:,3));

errParams.amountClasses = amountClasses;
errParams.description   = plotTitle;
errParams.evalMetric = 1/size(helpVec, 1) * sum(arrayfun(@(x) (1+cos(x))/2, helpVec));
% parameter for saving the plot
errParams.print         = true;
errParams.plotName      = sprintf('error_%s', config);
errParams.saveLocation  = fullfile(plotDirectory, 'error_plots');

errParams.mode          = 'classes';
createErrorPlot(results, errParams);

errParams.mode          = 'difficulties';
createErrorPlot(results, errParams);

% Image examples plot
exParams.amountImages   = 36;
exParams.description    = plotTitle;
exParams.startingPoint  = 0;
% parameter for saving the plot
exParams.print          = true;
exParams.saveLocation   = fullfile(plotDirectory, 'image_examples');

exParams.mode           = 'worst';
exParams.plotName       = sprintf('imgEx_%s_%sOffset%d', config, exParams.mode, ...
    exParams.startingPoint);
worstLocs = createImgExamplePlot(resrams);

exParams.mode           = 'best';
exParams.plotName       = sprintf('imgEx_%s_%sOffset%d', config, exParams.mode, ...
    exParams.startingPoint);
createImgExamplePlot(results, exParams);

%% Other

myHelperDisplayConfusionMatrix(confMat, amountClasses, 'relative');