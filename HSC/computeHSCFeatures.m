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
        img = imread(imgLocation);
        
        feature = computeHSCFeatureForImage(img, D, imgParams, spamsParams);
        
        featureVectors = [featureVectors; feature];
        
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