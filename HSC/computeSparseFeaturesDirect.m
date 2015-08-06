function [features, classLabels] = computeSparseFeaturesDirect(imgSet, ...
    distinctClassLbls, imgParams, D, spamsParam)
tic
fprintf('Compute the sparse features of "%s" ... ', inputname(1));

indices = getDistinctPatchIndices(imgParams.imgSize, imgParams.patchSize);

features    = [];
classLabels = [];

reverseStr = '';
amountClasses = size(imgSet,2);
parfor i=1:amountClasses
    
    currentImgSet = imgSet(1,i);
    imagesInCurrClass = currentImgSet.Count;
    
    for j=1:imagesInCurrClass
        
        slidingImgPatches = computeUniformPatches(currentImgSet.ImageLocation{1,j}, ...
            imgParams);
        
        % select only distinct patches (no overlapping)
        distinctImgPatches = slidingImgPatches(:,indices);
        % get the alphas
        alphaDistinct = mexLasso(distinctImgPatches,D,spamsParam);
        % convert to full matrix to obtain indices of maximum values
        alphaFull = full(alphaDistinct);
        [~, maxAbsIdx] = max(abs(alphaFull), [], 1);
        % each distinct patch is represented by the number [index] of the element from the
        % dictionary which has the highest value [max(abs(x))] in the reconstruction;
        % concatenation of these indices result in the feature vector.
        features = [features; maxAbsIdx];
        
    end
    currLabels = repmat(distinctClassLbls{1,i}, imagesInCurrClass, 1);
    classLabels = [classLabels; currLabels];
    
end
t = toc;
fprintf(' ... DONE! Computing time: %f\n', t);
end