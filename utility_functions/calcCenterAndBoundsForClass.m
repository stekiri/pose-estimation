function [centers, bounds, labels] = calcCenterAndBoundsForClass(numClasses)
%calcCenterAndBoundsForClass Calculate the centers and bounds for each class.
% Returns the centers as well as the lower and upper bounds of the each
% class. These depend on the number of classes used.

% calculation for centers
discreteAngles = [-pi:2 * pi / numClasses:pi];
centers = round(discreteAngles(1,2:length(discreteAngles)), 2);

% calculations for bounds
helpingPoints = linspace(-3.14, 3.14, 2 * numClasses + 1);
bounds = [];
% create bins
for idx = 1:numClasses
    if helpingPoints(2 * idx + 1) == 3.14
        lowerBinLimit = helpingPoints(end - 1);
        upperBinLimit = helpingPoints(2);
    else
        lowerBinLimit = helpingPoints(2 * idx);
        upperBinLimit = helpingPoints(2 * idx + 2);
        
    end
    newBin = [lowerBinLimit upperBinLimit];
    bounds = [bounds; newBin];
end

labels = cell(1,numClasses);
for k = 1:numClasses
    labels{1,k} = sprintf('%02d_%+0.2f', k, centers(k));
end

end