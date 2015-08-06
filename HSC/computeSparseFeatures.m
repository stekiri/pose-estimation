function [features, classLabels] = computeSparseFeatures(imagePatches, ...
    distinctClassLbls, imgParams, D, spamsParam)

fprintf('Compute the sparse features of "%s" ... ', inputname(1));

indices = getDistinctPatchIndices(imgParams.imgSize, imgParams.patchSize);

features    = [];
classLabels = [];

reverseStr = '';
amountClasses = size(imagePatches,2);
for i=1:amountClasses
    
    currentClass = imagePatches{1,i};
    imagesInCurrClass = size(currentClass,2);
    
    for j=1:size(currentClass,2)
        
        currImgPatch = currentClass{1,j};
        % select only distinct patches (no overlapping)
        currImgPatchDistinct = currImgPatch(:,indices);
        % get the alphas
        alphaDistinct = mexLasso(currImgPatchDistinct,D,spamsParam);
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
    
    % display progress
    msg = sprintf('%d/%d', i, amountClasses);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
fprintf(' ... DONE!\n');
end