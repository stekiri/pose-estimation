function [f, imagesPerClass] = plotDistributionOfImages(imgSet, numClasses, params)
%plotDistributionOfImages Plots the amount of images per class.
% [f, imagesPerClass] = plotDistributionOfImages(imgSet, numClasses, params)
% creates a plot which contains the number of images per class. numClasses
% specifies the amount of distinct classes. imgSet is an ImageSet object
% and contains all images.

if size(imgSet, 2) == 1
    
    imagesPerClass = getAmountOfImagesPerClass(imgSet, numClasses);

% if imgSet consists of nested image sets already pre-sorted into classes
else
    setClasses = size(imgSet, 2);
    if setClasses ~= numClasses
        fprintf('WARNING: Amount of specified classes inconsistent with imageset!\n')
    end
    imagesPerClass = zeros(1, setClasses);
    for j = 1:setClasses
        imagesPerClass(1, j) = imgSet(1, j).Count;
    end
end

% determine y-limit depending on the difficulty
switch params.difficulty
    case 'easy'
        yLimit = 2000;
    case 'moderate'
        yLimit = 6000;
    case 'hard'
        yLimit = 8000;
end

% Plot histogram
f = figure;
bar(imagesPerClass);
% lower limit set to 0.01 so that '0' on x-axis is not visible
xlim([0.01 numClasses+1])
title({'images per class', sprintf('- %s -', inputname(1))})
ylim([0 yLimit])

if params.print == true
    fileName = sprintf('%s_%s.png', params.plotName, inputname(1));
    saveas(f, fullfile(params.saveLocation, fileName));
end
end
