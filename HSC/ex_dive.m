

%% iteration to get indices for non-overlapping patches

width = size(I, 2);
height = size(I, 1);
patchsizeW = 8;
patchsizeH = 8;

horizOffset = width - patchsizeW + 1;

indices = [];

for j=1:height/patchsizeW
    for i=1:width/patchsizeW   
        index = 1 + patchsizeW*(i-1) + patchsizeH*horizOffset*(j-1);
        indices = [indices index];
    end
end

%% extract relevant alphas only
alphaNew = alpha(:, indices);

alphaNonS = full(alphaNew);

[maxAbs, maxIdx] = max(abs(alphaNonS), [], 1);

% extract the exact values
amountOfPatches = size(alphaNew, 2);
maxExact = zeros(1, amountOfPatches);
for i=1:amountOfPatches
    maxExact(1,i) = alphaNew(maxIdx(i),i);
end

%% reconstruct original image

% first line
amountPatches = 4096;
patchSize = 64;


patchesFirst = zeros(patchSize,amountPatches);
for i=1:amountPatches
    patchesFirst(:,i) = D(:,maxIdx(1,i)) * maxExact(1,i);
end

reconImg = col2im(patchesFirst,[8 8], [512 512], 'distinct');
figure;
subplot(1,2,1);
imshow(I);
subplot(1,2,2);
imagesc(reconImg); colormap('gray');


%% other

A = col2im(sum(X), [8 8], [512 512], 'sliding');
figure; imagesc(A); colormap('gray');

Xred = X(:, indices);
alphaRed=mexLasso(Xred,D,param);

