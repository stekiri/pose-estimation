plotDirectory       = '/home/steffen/Dropbox/Aktuelles_Semester/Masterarbeit/Matlab_files/figures';

%% set parameters
imgParams.imgSize = [80 160]; % multiples of patchSize
imgParams.patchSize = [8 8];

%% load images for DL

imgSetPath = '/home/steffen/Dokumente/KITTI/experiments/classified_images/easy_cl16_mir150_rem150';
trainingSet = imageSet(fullfile(imgSetPath, 'training'),'recursive');
testSet = imageSet(fullfile(imgSetPath, 'test'),'recursive');

% trainImagePatches = prepareImgSet(trainingSet, imgParams);
% testImagePatches  = prepareImgSet(testSet,     imgParams);

%% dictionary params
param.K=256;  % learns a dictionary with 256 elements
param.mode=3;
param.lambda=1;
param.numThreads=-1; % number of threads
param.batchsize=400;
param.verbose=false;
param.iter=250;

%% learn dictionary

% choose subset of images for DL
trainSubSet = removeImgsFromSet(trainingSet, 10);

% learning
[D, model] = learnDictionary(trainSubSet, imgParams, param);

ImD=displayPatches(D);
imagesc(ImD); colormap('gray');
drawnow;

%% load images for feature construction

% same as for DL

%% retrieve features

distinctClassLbls = cell(1,size(trainingSet, 2));
for i=1:size(trainingSet,2)
    distinctClassLbls{1,i} = trainingSet(1,i).Description;
end

[trainFeat, trainExactLabels, trainClassLabels, trainLocations] = ...
    computeSparseFeaturesDirectVer2(trainingSet, distinctClassLbls, imgParams, D, param);
[testFeat,  testExactLabels,  testClassLabels,  testLocations]  = ...
    computeSparseFeaturesDirectVer2(testSet,     distinctClassLbls, imgParams, D, param);
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
reconstructImage(imgLocation, imgParams, D, param);
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