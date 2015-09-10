function [modImg, actualCell] = createValidImage(img, dimension, hogsPerDim)
%createValidImage Create a valid image for HOG feature computation.
% [modImg, actualCell] = createValidImage(img, dimension, hogsPerDim)
% creates a valid image for the computation of HOG features. This is
% necessary due to incorrect behavior of the built-in HOG feature
% computation.

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
