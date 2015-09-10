% Script to learn dictionary with the SPAMS library.

%% Learn dictionary

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
