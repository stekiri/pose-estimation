function imgPatches = computeUniformPatches(imgLocation, imgParams)

img = imread(imgLocation);
% resize to average size
imgResized = imresize(img, imgParams.imgSize);
% preprocess
imgPatches = preprocessImage(imgResized, imgParams.patchSize);

end