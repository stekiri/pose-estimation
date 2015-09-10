function indices = getDistinctPatchIndices(imgSize, patchSize)
%getDistinctPatchIndices Get the indices of distinct patches.
% indices = getDistinctPatchIndices(imgSize, patchSize) return all the
% indices of distinct patches. This indices can be used to reconstruct an
% image.

height = imgSize(1,1);
width  = imgSize(1,2);

patchSizeH = patchSize(1,1);
patchSizeW = patchSize(1,2);

% number of patches per row
horizOffset = width - patchSizeW + 1;

indices = [];

for j=1:height/patchSizeW
    for i=1:width/patchSizeW   
        index = 1 + patchSizeW*(i-1) + patchSizeH*horizOffset*(j-1);
        indices = [indices index];
    end
end

end
