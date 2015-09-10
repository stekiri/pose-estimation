% Script to display the patches from a computed dictionary.

blackline = repmat([-1], 8, 1);
multPatches = [blackline];

for j=1:16
    
    imgRow = D(:,j);
    
    img = zeros(8);
    for i=1:8
        img(:,i) = imgRow(((i-1)*8 + 1):(i*8), 1)';
    end
    
    multPatches = [multPatches img blackline];
end

figure; colormap('gray');
imagesc(multPatches);
