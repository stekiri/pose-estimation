function indices = getDistinctPatchIndices(imgSize, patchSize)

height = imgSize(1,1);
width  = imgSize(1,2);

patchSizeH = patchSize(1,1);
patchSizeW = patchSize(1,2);

horizOffset = width - patchSizeW + 1;

indices = [];

for j=1:height/patchSizeW
    for i=1:width/patchSizeW   
        index = 1 + patchSizeW*(i-1) + patchSizeH*horizOffset*(j-1);
        indices = [indices index];
    end
end

end