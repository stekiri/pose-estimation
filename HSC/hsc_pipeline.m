%% Startup

% Execute hog_pipeline.m up until Step 8 (feature extraction)

%% learn dictionary

% load image set
dlTrainSet = imageSet('/home/steffen/Dokumente/KITTI/experiments/allImages_1fold_16classes', 'recursive');

% choose subset of images for DL
dlTrainSubSet = removeImgsFromSet(dlTrainSet, 10);

% learning
dictLength = [25, 36, 49];
for d=1:length(dictLength)
    spamsParams.K = dictLength(d)
    [D, model] = learnDictionary(dlTrainSubSet, imgParams, spamsParams);
    save(sprintf('dictionaries/length_%d.mat', dictLength(d)), 'D', 'model');
end

ImD=displayPatches(D);
figure;
imagesc(ImD); colormap('gray');
drawnow;

%% load images for feature construction

% same as for DL

%% retrieve features

hscParams.binning = 'hard'; % alternatives: 'soft', 'hard'

for j=1:length(dictLength)
    
    fprintf('dictionary length: %d\n', dictLength(j))
    
    spamsParams.K = dictLength(j);
    load(sprintf('dictionaries/length_%d.mat', dictLength(j)))
    
    for i=1:processParams.folds
        fprintf('fold#%d\n', i);
        currFoldName = sprintf('fold_%02d', i);
        imgSetOfCurrFold = imageSet(fullfile(dirs.classified, processParams.classifFolder, currFoldName), 'recursive');
        [currFold.features, currFold.exactLabels, currFold.classLabels, currFold.locations] = ...
            computeHSCFeatures(imgSetOfCurrFold, D, processParams, imgParams, spamsParams, ...
            hscParams);
        % allFoldsData{1,i} = currFold;
        save(sprintf('features/dictLength_%d_%s.mat', spamsParams.K, currFoldName), 'currFold')
    end
    
    % splitted to prevent break down

    % to reload data into one file
    for i=1:processParams.folds
        load(sprintf('features/dictLength_%d_fold_%02d.mat', spamsParams.K, i))
        allFoldsData{1,i} = currFold;
    end
    save(sprintf('features/hsc_features_dictLength_%d.mat', spamsParams.K), 'allFoldsData')
end

% dimensionality reduction with pca?
% example: http://www.mathworks.com/help/stats/feature-transformation.html#f75476


%% OLD STUFF

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