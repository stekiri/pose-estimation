function [featureVectors, exactLabels, classLabels, locations] = ...
    extractHOGFeaturesFromImageSet(imageSets, params)

if sum(params.blockSize > params.amountHOGs) > 0
    error('Parameters incompatible (blockSize and amountHOGs)');
end

fprintf('Extract HOG features from "%s" images ... ', inputname(1));
% initialize data objects
featureVectors = [];
exactLabels    = [];
classLabels    = [];
locations      = cell(0, 1);

% calculate length of feature vector
hogFeatureSize = params.numBins * params.blockSize(1) * params.blockSize(2) * ...
    (params.amountHOGs(1) - params.blockOverlap(2)) * (params.amountHOGs(2) - ...
    params.blockOverlap(1));

amountClasses = numel(imageSets);
reverseStr = '';
for idx = 1:amountClasses
    
    currImgSet = imageSets(idx);
    numImages = currImgSet.Count;
    features  = zeros(numImages, hogFeatureSize, 'single');
    
    for i = 1:numImages
        
        img = read(currImgSet, i);
        % image has to be cropped in some cases due to floor function for HOG creation
        % check x-dimension
        [img, cellSizeX] = createValidImage(img, 2, params.amountHOGs(1));
        % check y-dimension
        [img, cellSizeY] = createValidImage(img, 1, params.amountHOGs(2));
        
        cellSize = [cellSizeY cellSizeX];
        
        features(i, :) = extractHOGFeatures(img, 'CellSize', cellSize, 'BlockSize', ...
            params.blockSize, 'NumBins', params.numBins, 'BlockOverlap', ...
            params.blockOverlap);
        
        % get label and location from fileName
        imagePath = currImgSet.ImageLocation{i};
        [~, angle, ~, ~, ~, ~, ~] = getImageProperties(imagePath);
        locations = [locations; imagePath]; %#ok<AGROW>
        exactLabels = [exactLabels; angle];     %#ok<AGROW>
    end
    
    featureVectors = [featureVectors; features];   %#ok<AGROW>
    % Use the imageSet Description as the training labels
    labels = repmat(currImgSet.Description, numImages, 1);
    classLabels   = [classLabels;   labels  ];   %#ok<AGROW>
    
    % display progress
    msg = sprintf('%d/%d', idx, amountClasses);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
fprintf(' ... DONE!\n');
end