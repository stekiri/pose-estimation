function class = getClassAssignment(angle, numClasses)
%getClassAssignment Get the class assignment of an angle.
% Utilized when it is necessary to determine to which class (front, back,
% etc.) a specific image belongs to.

[~, classBins] = calcCenterAndBoundsForClass(numClasses);
class = 0;
for j = 1:numClasses
    if angle >= classBins(numClasses, 1) | angle < classBins(numClasses, 2)
        class = numClasses;
    elseif angle >= classBins(j, 1) & angle < classBins(j, 2)
        class = j;
    end
    
end

end