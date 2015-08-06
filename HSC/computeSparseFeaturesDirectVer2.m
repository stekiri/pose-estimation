function [featureVectors, exactLabels, classLabels, locations] = computeSparseFeaturesDirectVer2(imgSet, ...
    distinctClassLbls, imgParams, D, spamsParam)
tic
fprintf('Compute the sparse features of "%s" ... ', inputname(1));

indices = getDistinctPatchIndices(imgParams.imgSize, imgParams.patchSize);

featureVectors = [];
exactLabels    = [];
classLabels    = [];
locations      = cell(0,1);

amountClasses = size(imgSet,2);
for i=1:amountClasses
    
    currentImgSet = imgSet(1,i);
    imagesInCurrClass = currentImgSet.Count;
    
    for j=1:imagesInCurrClass
        
        imgLocation = currentImgSet.ImageLocation{1,j};
        
        slidingImgPatches = computeUniformPatches(imgLocation, imgParams);
        
        % select only distinct patches (no overlapping)
        distinctImgPatches = slidingImgPatches(:,indices);
        % get the alphas
        alpha = mexLasso(distinctImgPatches,D,spamsParam);
        
        alpha = abs(alpha);
        
        alpha = reshape(alpha, 1, size(alpha,1)*size(alpha,2));
        
        % normalize alpha 
        % --- TODO: normalization column-wise before??
        alpha = alpha/norm(alpha);
        
        featureVectors = [featureVectors; alpha];
        
        
        % ---- TODO: implement soft binning ----
                
        % --------------------------------------
        
        [~, angle] = getImageProperties(imgLocation);
        exactLabels = [exactLabels; angle];
        locations = [locations; imgLocation];
                
    end
    currLabels = repmat(distinctClassLbls{1,i}, imagesInCurrClass, 1);
    classLabels = [classLabels; currLabels];
    
end
t = toc;
fprintf('DONE! Computing time: %f\n', t);
end