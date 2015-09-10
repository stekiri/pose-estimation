function reconstructImage(imgLocation, imgParams, D, spamsParam)
%reconstructImage Reconstruct an image.
% reconstructImage(imgLocation, imgParams, D, spamsParam) returns the
% reconstruction of an image by using only distinct patches which are
% the closest to the original patch.

slidingImgPatches = computeUniformPatches(imgLocation, imgParams);

indices = getDistinctPatchIndices(imgParams.imgSize, imgParams.patchSize);
distinctImgPatches = slidingImgPatches(:,indices);

% get the sparse codes
alpha = mexLasso(distinctImgPatches,D,spamsParam);

% reconstruct image
reconImgColumns = D*alpha;
reconImg = col2im(reconImgColumns, imgParams.patchSize, imgParams.imgSize, 'distinct');

figure;
subplot(2,1,1);
imshow(imgLocation);
title('Original Image:')
subplot(2,1,2);
imagesc(reconImg); colormap('gray');
set(gca,'XTickLabel', [])
set(gca,'YTickLabel', [])
title('Reconstructed Image:')

set(f, 'Position', [0 0 500 600])

end
