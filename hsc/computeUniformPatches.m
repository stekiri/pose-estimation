function imgPatches = computeUniformPatches(img, imgParams)

% resize to average size
imgResized = imresize(img, imgParams.imgSize);
% preprocess
imgPatches = preprocessImage(imgResized, imgParams.patchSize);

end