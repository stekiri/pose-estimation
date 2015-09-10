% script to obtain the average dimensions of images in the ImageSet imgSet

allHeights = [];
allWidths  = [];

for i=1:size(imgSet,2)
    for j = 1:imgSet(1,i).Count
        img = imread(imgSet(1,i).ImageLocation{1,j});
        height = size(img,1);
        width  = size(img,2);
        allHeights = [allHeights; height];
        allWidths  = [allWidths;  width ];
    end
end

allSizes = [allHeights .* allWidths];

dimensions = [allHeights, allWidths, allSizes];

mean(dimensions)
min(dimensions)
max(dimensions)
