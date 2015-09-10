% Script to create a sparse code visualizations.

imgLocation = dlTrainSubSet(1,3).ImageLocation{1,8};
figure;
imshow(imgLocation)

slidingImgPatches = computeUniformPatches(imgLocation, imgParams);

alpha = mexLasso(slidingImgPatches,D,spamsParams);

amountSC = zeros(size(alpha,2),1);
for i=1:size(alpha,2)
    amountSC(i,1) = nnz(alpha(:,i));
end

% find patches with small number of sparse codes
[m idx] = sort(amountSC);

%% for presentation example
chosenPatchIdx = 5544;
specificPatch = slidingImgPatches(:,chosenPatchIdx);
reshapedPatch = reshape(specificPatch,imgParams.patchSize);

figure;
imagesc(reshapedPatch); colormap('gray');
drawnow;

idxOfNonZeros = find(alpha(:,chosenPatchIdx))';
weights = alpha(:,chosenPatchIdx)

dictPatches = D(:,idxOfNonZeros);

for i=1:size(dictPatches,2)
    reshapedDictPatch = reshape(dictPatches(:,i),imgParams.patchSize);
    figure;
    imagesc(reshapedDictPatch); colormap('gray');
    drawnow;
end

% sum up the reconstruction images with their weight to reconstruct image patch
reconPatch = D*weights;
reshapedReconPatch = reshape(reconPatch,imgParams.patchSize);
figure;
imagesc(reshapedReconPatch); colormap('gray');
drawnow;
