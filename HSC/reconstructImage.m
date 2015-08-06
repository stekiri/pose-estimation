function f = reconstructImage(imgLocation, imgParams, D, spamsParam)

slidingImgPatches = computeUniformPatches(imgLocation, imgParams);

indices = getDistinctPatchIndices(imgParams.imgSize, imgParams.patchSize);
distinctImgPatches = slidingImgPatches(:,indices);

% get the alphas
alpha = mexLasso(distinctImgPatches,D,spamsParam);

% reconstruct image
reconImgColumns = D*alpha;
reconImg = col2im(reconImgColumns, imgParams.patchSize, imgParams.imgSize, 'distinct');

f = figure;
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