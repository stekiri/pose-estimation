function X = preprocessImage(img, patchSize)

if size(img, 3) > 1
    img = rgb2gray(img);
end

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