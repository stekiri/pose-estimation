function imagesPerClass = getAmountOfImagesPerClass(imgSet, numClasses)
%getAmountOfImagesPerClass Get the number of images per class.

angles = zeros(imgSet.Count, 1);
for i = 1:imgSet.Count
    [~, angle, ~, ~, ~, ~, ~] = getImageProperties(imgSet.ImageLocation{1, i});
    angles(i, 1) = angle;
end
numClassesRep = repmat(numClasses, imgSet.Count, 1);
classAssignment = arrayfun(@getClassAssignment, angles, numClassesRep);

imagesPerClass = zeros(1, numClasses);
for j = 1:numClasses
    imagesPerClass(1, j) = sum(classAssignment(:,1) == j);
end

end