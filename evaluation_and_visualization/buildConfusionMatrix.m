function confMat = buildConfusionMatrix(truthLabels, predictedLabels, numClasses)
%buildConfusionMatrix Build a confusion matrix.
% confMat = buildConfusionMatrix(truthLabels, predictedLabels, numClasses)
% computes the confusion matrix which indicates how many predictions were
% correct and incorrect.

confMat = zeros(numClasses);

for i=1:numClasses
    for j=1:numClasses
        confMat(i,j) = sum(truthLabels == i & predictedLabels == j);
    end
end

end
