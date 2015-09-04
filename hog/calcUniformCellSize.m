function [cellSize, modImg] = calcUniformCellSize(img, amountHOGs)

imgWidth = size(img, 2)
imgHeight = size(img, 1)

cellSize = zeros(1, 2);
cellSize(2) = imgWidth / amountHOGs(1)
cellSize(1) = imgHeight / amountHOGs(2)

cellSize = floor(cellSize);


modImg = img;

for i = 1:numel(cellSize)

    ratio = size(img, i) / cellSize(i)
    if (ratio == floor(ratio)) && (size(img, i) / cellSize(i) ~= amountHOGs(3 - i)) 
        % crop image by one pixel
        'cropping'
        modImg = cropImage(modImg, i, 1);
        size(modImg)
        cellSize(i) = size(modImg, i) / amountHOGs(3 - i)
    end
end

cellSize = floor(cellSize);

end