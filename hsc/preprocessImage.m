function X = preprocessImage(img, patchSize)
%preprocessImage Preprocess images for sparse coding.
% X = preprocessImage(img, patchSize) extracts all patches from an image
% in a sliding window approach. These patches are then centered and
% normalized.

% convert to gray if necessary
if size(img, 3) > 1
    img = rgb2gray(img);
end
% set pixel values in between 0 and 1
imgDouble = double(img)/255;
% extract patches
X=im2col(imgDouble,patchSize,'sliding');
% centering
X=X-repmat(mean(X),[size(X,1) 1]);
% normalization
X=X ./ repmat(sqrt(sum(X.^2)),[size(X,1) 1]);
% replace NaN values in matrix with zeros
X(isnan(X)) = 0;

end
