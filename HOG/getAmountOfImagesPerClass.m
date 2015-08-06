function imagesPerClass = getAmountOfImagesPerClass(imgSet, amountClasses)

angles = zeros(imgSet.Count, 1);
for i = 1:imgSet.Count
    [~, angle, ~, ~, ~, ~, ~] = getImageProperties(imgSet.ImageLocation{1, i});
    angles(i, 1) = angle;
end
amountClassesRep = repmat(amountClasses, imgSet.Count, 1);
classAssignment = arrayfun(@getClassAssignment, angles, amountClassesRep);

imagesPerClass = zeros(1, amountClasses);
for j = 1:amountClasses
    imagesPerClass(1, j) = sum(classAssignment(:,1) == j);
end

end