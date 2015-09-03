%% Load all parameters

fprintf('Are you cross-validating on the training set or predicting on the test set?\n')
fprintf('Consider adjustments?\n')

% add paths
addpath(genpath('/home/steffen/Dropbox/Aktuelles_Semester/Masterarbeit/Matlab_files'));
addpath(genpath('/home/steffen/MATLAB/R2015a/SupportPackages/toolbox-piotr'));

% general directories
dirs.work           = '/home/steffen/Dokumente/KITTI';
dirs.plot           = '/home/steffen/Dropbox/Aktuelles_Semester/Masterarbeit/Matlab_files/figures';
dirs.sourceLabel    = fullfile(dirs.work, 'label_2');
dirs.experiments    = fullfile(dirs.work, 'experiments');
dirs.folds          = fullfile(dirs.experiments, 'folds-split');
dirs.foldsDrives    = fullfile(dirs.experiments, 'folds-drives-split');
dirs.crop           = fullfile(dirs.experiments, 'cropped_images');
dirs.classified     = fullfile(dirs.experiments, 'classified_images');

% parameters

% - for extraction of object images
extractParams.difficulty          = 'easy';
% Difficulties as proposed on KITTI homepage
switch extractParams.difficulty
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

% - for process variables
processParams.folds         = 10;
processParams.classes       = 16;
processParams.cropFolder    = sprintf('cv_%s_%s_rf%d', ...
    extractParams.difficulty, extractParams.mode, extractParams.removalFrequency);
processParams.classifFolder = sprintf('%s_cl%d', ...
    processParams.cropFolder, processParams.classes);
processParams.folderAllImages = fullfile(dirs.crop, sprintf('%s_allImages', ...
    processParams.cropFolder));
load(strcat(processParams.cropFolder, '_allImages.mat'))
processParams.imgsPerClass  = imgsPerClass;
processParams.featureName   = 'HSC'; % alternatives: 'HOG', 'HSC'

% - for plotting of the images per class
distrParams.print        = false;
distrParams.saveLocation = fullfile(dirs.plot, 'images_per_class');
distrParams.plotName     = 'imgPerClass';
distrParams.difficulty   = extractParams.difficulty;

% - for predictions
predParams = struct(...
    'reduceDimensionality', false,...
    'reductionMode', '-',... % alternatives: only 'pca' so far
    'reducedFeatLength', 0,...
    'model', 'combClassRegr',...
    'threshold', 0,... % 0 -> only classification, 3.14 -> only regression
    'classifLibrary', 'libsvm',...  % alternatives: 'matlab', 'libsvm'
    'regrLibrary', 'matlab', ...    % alternatives: 'matlab', 'libsvm'
    'kernel', 'linear',...          % alternatives: 'linear, 'polynomial', 'rbf'
    'coding', 'onevsone',...        % alternatives: 'onevsall', 'onevsone', 'onevsone_custom'
    'weights', 'noWeights',...% alternatives: 'noWeights', 'automaticWeights'
    'weightFactor', 0,...
    'imgsPerClass', processParams.imgsPerClass,...
    'computeProbs', false,...
    'voting', 'majority',...        % alternatives: 'majority', 'probs', 'weighted_voting', 'inv_weighted_voting', 'specialized'
    'mode', 'reduced',...           % alternatives: 'reduced', 'all'
    'svmParameter', struct('C', '0.25', 'gamma', '-'),... % C amd gamma should be set to '-' when cross-validation is performed
    'saveModel', false);            % save SVM model in result variable (can get large)

processParams.predictionModel = sprintf('%s%0.2f_%s_%s_%s_%s', predParams.model, ...
    predParams.threshold, predParams.classifLibrary, predParams.kernel, predParams.coding, ...
    predParams.weights);
processParams.configuration = sprintf('%s_%s_%s', ...
    processParams.classifFolder, processParams.featureName, processParams.predictionModel);

% - for HOG
hogParams.amountHOGs      = [6 4];
hogParams.numBins         = 9;
hogParams.blockSize       = [2 2];
hogParams.blockOverlap    = ceil(hogParams.blockSize / 2);

% - for HSC
imgParams.imgSize       = [64 120]; % multiples of patchSize
imgParams.patchSize     = [8 8];
imgParams.amountCells   = [4 6];

% - for SPAMS
spamsParams.K=64;  % learns a dictionary with K elements
spamsParams.mode=3;
spamsParams.lambda=1;
spamsParams.numThreads=-1; % number of threads
spamsParams.batchsize=400;
spamsParams.verbose=false;
spamsParams.iter=250;