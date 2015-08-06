function [featureVectors, exactLabels, classLabels, locations] = computeHSCFeatures(...
    imgSet, D, processParams, imgParams, spamsParams, hscParams)
tic
fprintf('Compute the sparse features of "%s" ... \n', inputname(1));

% initialize
featureVectors = [];
exactLabels    = [];
classLabels    = [];
locations      = cell(0,1);

classesInSet = size(imgSet,2);
for i=1:classesInSet
    
    fprintf('class#%d\n', i);
    
    currentImgSet = imgSet(1,i);
    imagesInCurrClass = currentImgSet.Count;
    
    for j=1:imagesInCurrClass
        
        imgLocation = currentImgSet.ImageLocation{1,j};
        
        slidingImgPatches = computeUniformPatches(imgLocation, imgParams);
        
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
        
        featureVectors = [featureVectors; feature];
        
        
        % ---- TODO: implement soft binning ----
                
        % --------------------------------------
        
        [~, angle] = getImageProperties(imgLocation);
        exactLabels = [exactLabels; angle];
        locations = [locations; imgLocation];
                
    end
    currClassLabels = repmat(currentImgSet.Description, imagesInCurrClass, 1);
    classLabels = [classLabels; currClassLabels];
    
end
t = toc;
fprintf('DONE! Computing time: %f\n', t);
end