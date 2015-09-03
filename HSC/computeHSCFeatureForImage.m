function feature = computeHSCFeatureForImage(img, D, imgParams, spamsParams)

slidingImgPatches = computeUniformPatches(img, imgParams);

alpha = mexLasso(slidingImgPatches,D,spamsParams);

% initialize all cells and set values in cells to zero
featureCell = cell(imgParams.amountCells);
for r=1:imgParams.amountCells(1)
    for s=1:imgParams.amountCells(2)
        featureCell{r,s} = zeros(spamsParams.K, 1);
    end
end

% go through all image patches
for k=1:size(alpha,2)
    % get the absolute values for the current patch
    scAtCurrentPixel = abs(alpha(:,k));
    % to which cell does the current patch belong to
    currentCell = getAssignmentToCell(k, imgParams);
    % sum up the feature with the existing values to obtain histogram
    featureCell{currentCell(1,1),currentCell(1,2)} = ...
        featureCell{currentCell(1,1),currentCell(1,2)} + scAtCurrentPixel;
end

% normalize the values per cell
for r=1:imgParams.amountCells(1)
    for s=1:imgParams.amountCells(2)
        featureCell{r,s} = featureCell{r,s} / norm(featureCell{r,s});
    end
end

feature = [];
% concatenate feature vector
for r=1:imgParams.amountCells(1)
    for s=1:imgParams.amountCells(2)
        feature = [feature; featureCell{r,s}];
    end
end
% transpose
feature = feature';

% ---- TODO: implement soft binning ----

% --------------------------------------

end