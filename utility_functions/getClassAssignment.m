function class = getClassAssignment(angle, amountClasses)

[~, classBins] = calcCenterAndBoundsForClass(amountClasses);
class = 0;
for j = 1:amountClasses
    if angle >= classBins(amountClasses, 1) | angle < classBins(amountClasses, 2)
        class = amountClasses;
    elseif angle >= classBins(j, 1) & angle < classBins(j, 2)
        class = j;
    end
    
end

end