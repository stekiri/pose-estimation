function imgPatches = computeUniformPatches(img, imgParams)
%computeUniformPatches Compute uniform patches.
% imgPatches = computeUniformPatches(img, imgParams) resizes image and
% preprocesses the image uniformly.

% resize to average size
imgResized = imresize(img, imgParams.imgSize);
% preprocess
imgPatches = preprocessImage(imgResized, imgParams.patchSize);

end
