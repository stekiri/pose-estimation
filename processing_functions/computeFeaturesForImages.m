function [featureVectors, exactLabels, classLabels, locations] = ...
    computeFeaturesForImages(imgSet, featureParams, featureName)

if strcmp(featureName, 'HOG')
    if sum(featureParams.blockSize > featureParams.amountHOGs) > 0
        error('Parameters incompatible (blockSize and amountHOGs)');
    end
end

tic
fprintf('Compute the %s features of "%s" ... \n', featureName, inputname(1));

% initialize
featureVectors = [];
exactLabels    = [];
classLabels    = [];
locations      = cell(0,1);

% calculate length of feature vector to initialize feature vectors
switch featureName
    case 'HOG'
        featureLength = featureParams.numBins * ...
            featureParams.blockSize(1) * featureParams.blockSize(2) * ...
            (featureParams.amountHOGs(1) - featureParams.blockOverlap(2)) * ...
            (featureParams.amountHOGs(2) - featureParams.blockOverlap(1));
        
    case 'HSC'
        featureLength = featureParams.hscParams.amountCells(1,1) * ...
            featureParams.hscParams.amountCells(1,2) * ...
            featureParams.spamsParams.K;
        
end

for i=1:size(imgSet,2)
    
    fprintf('class#%d\n', i);
    
    currentImgSet = imgSet(1,i);
    imagesInCurrClass = currentImgSet.Count;
    features  = zeros(imagesInCurrClass, featureLength, 'single');
    
    for j=1:imagesInCurrClass
        
        imgLocation = currentImgSet.ImageLocation{1,j};
        img = imread(imgLocation);
        
        switch featureName
            case 'HOG'
                % image has to be cropped in some cases due to floor function for HOG creation
                % check x-dimension
                [img, cellSizeX] = createValidImage(img, 2, featureParams.amountHOGs(1));
                % check y-dimension
                [img, cellSizeY] = createValidImage(img, 1, featureParams.amountHOGs(2));
                
                cellSize = [cellSizeY cellSizeX];
                
                features(j, :) = extractHOGFeatures(...
                    img, 'CellSize', cellSize, 'BlockSize', featureParams.blockSize, ...
                    'NumBins', featureParams.numBins, ...
                    'BlockOverlap', featureParams.blockOverlap);
                
            case 'HSC'
                features(j, :) = computeHSCForImage(img, featureParams.D, ...
                    featureParams.hscParams, featureParams.spamsParams);
        end
        % get the angle information from the current image and save it as a label
        [~, angle] = getImageProperties(imgLocation);
        exactLabels = [exactLabels; angle];
        locations = [locations; imgLocation];
    end
    % concatenate the vectors from the current class with the previous classes
    featureVectors = [featureVectors; features];
    % Use the imageSet Description as the training labels
    currClassLabels = repmat(currentImgSet.Description, imagesInCurrClass, 1);
    classLabels = [classLabels; currClassLabels];
end
t = toc;
fprintf('DONE! Computing time: %0.2f mins\n', t/60);
end