function [modImg, actualCell] = createValidImage(img, dimension, hogsPerDim)

modImg = img;
imgSize = size(img, dimension);
estimatedCell = floor(imgSize / hogsPerDim);

actualCell = estimatedCell;

if (floor(imgSize / estimatedCell) ~= hogsPerDim)
    % crop image
    croppedImg = cropImage(img, dimension, 1);
    % check cropped image recursively
    [modImg, actualCell] = createValidImage(croppedImg, dimension, hogsPerDim);
end

end