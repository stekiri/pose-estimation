%% Startup

% Execute hog_pipeline.m up until Step 8 (feature extraction)

%% set parameters
imgParams.imgSize       = [64 120]; % multiples of patchSize
imgParams.patchSize     = [8 8];
imgParams.amountCells   = [4 6];

%% dictionary params
spamsParams.K=256;  % learns a dictionary with 256 elements
spamsParams.mode=3;
spamsParams.lambda=1;
spamsParams.numThreads=-1; % number of threads
spamsParams.batchsize=400;
spamsParams.verbose=false;
spamsParams.iter=250;

%% learn dictionary

% choose subset of images for DL
trainSubSet = removeImgsFromSet(trainingSet, 10);

% learning
[D, model] = learnDictionary(trainSubSet, imgParams, spamsParams);

ImD=displayPatches(D);
imagesc(ImD); colormap('gray');
drawnow;

%% load images for feature construction

% same as for DL

%% retrieve features

hscParams.binning = 'hard'; % alternatives: 'soft', 'hard'

for i=1:processParams.folds
    fprintf('fold#%d\n', i);
    currFoldName = sprintf('fold_%02d', i);
    imgSetOfCurrFold = imageSet(fullfile(classifPath, classifFolder, currFoldName), 'recursive');
    [currFold.features, currFold.exactLabels, currFold.classLabels, currFold.locations] = ...
        computeHSCFeatures(imgSetOfCurrFold, D, processParams, imgParams, spamsParams, hscParams)
    % allFoldsData{1,i} = currFold;
    save(sprintf('fold_%02d.mat', i), 'currFold')
end

for i=1:processParams.folds
    load(sprintf('fold_%02d.mat', i))
    allFoldsData{1,i} = currFold;
end
save('hsc_features_6144dim.mat', 'allFoldsData')

% dimensionality reduction with pca?
% example: http://www.mathworks.com/help/stats/feature-transformation.html#f75476

distinctClassLbls = cell(1,size(trainingSet, 2));
for i=1:size(trainingSet,2)
    distinctClassLbls{1,i} = trainingSet(1,i).Description;
end

[trainFeat, trainExactLabels, trainClassLabels, trainLocations] = ...
    computeSparseFeaturesDirectVer2(trainingSet, distinctClassLbls, imgParams, D, spamsParams);
[testFeat,  testExactLabels,  testClassLabels,  testLocations]  = ...
    computeSparseFeaturesDirectVer2(testSet,     distinctClassLbls, imgParams, D, spamsParams);
% for classifier learning full matrix is necessary
trainFeat = full(trainFeat);
testFeat = full(testFeat);

%% learn classifier
learner = templateSVM('KernelFunction','linear');
fprintf('Learn classifier ...');
tic
classifier = fitcecoc(trainFeat, trainClassLabels, 'Learners', learner);
t = toc;
fprintf('Computing time: %f\n', t);

%% predict
predictedLabels = predict(classifier, testFeat);

%% evaluate

predLabelsDouble = char2double(predictedLabels);

diff = arrayfun(@getAngleBetweenRadians, predLabelsDouble, testExactLabels);
results = {predLabelsDouble, testExactLabels, diff, testLocations};

%% Print metrics and show plots

config = sprintf('16clDict_easy_cl16_mir150_rem150_02');
plotTitle = 'histogram of sparse codes';
amountClasses = 16;

% print metrics
metrParams.description = plotTitle;
printResultMetrics(results, metrParams);

% Error plot
helpVec = cell2mat(results(:,3));

errParams.amountClasses = amountClasses;
errParams.description   = plotTitle;
errParams.cosSimilarity = 1/size(helpVec, 1) * sum(arrayfun(@(x) (1+cos(x))/2, helpVec));
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
worstLocs = createImgExamplePlot(results, exParams);

exParams.mode           = 'best';
exParams.plotName       = sprintf('imgEx_%s_%sOffset%d', config, exParams.mode, ...
    exParams.startingPoint);
createImgExamplePlot(results, exParams);


% Tabulate the results using a confusion matrix.
confMat = confusionmat(testClassLabels, predictedLabels);
myHelperDisplayConfusionMatrix(confMat, size(trainingSet, 2), 'absolute')

%% reconstruct (for visualisation)
for i=29:50
imgLocation = trainingSet(1,1).ImageLocation{1,1};
reconstructImage(imgLocation, imgParams, D, spamsParams);
end




% convert to full matrix to obtain indices of maximum values
alphaFull = full(alpha);
[maxAbsVal, maxAbsIdx] = max(abs(alphaFull), [], 1);

% extract the exact values
amountOfPatches = size(alpha, 2);
maxExactVal = zeros(1, amountOfPatches);
for k=1:amountOfPatches
    maxExactVal(1,k) = alpha(maxAbsIdx(k),k);
end

patchDim = patchSize(1,1)*patchSize(1,2);

patches = zeros(patchDim,amountOfPatches);
for i=1:amountOfPatches
    patches(:,i) = D(:,maxAbsIdx(1,i)) * maxExactVal(1,i);
end

% reconstruct
reconImg = col2im(patches, patchSize, imgSize, 'distinct');
figure;
subplot(1,2,1);
imshow(trainingSet(1,i).ImageLocation{1,j});
subplot(1,2,2);
imagesc(reconImg); colormap('gray');