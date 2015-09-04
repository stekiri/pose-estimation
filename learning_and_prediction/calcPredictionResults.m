function [results, confMat] = calcPredictionResults(prediction, testData, amountClasses)

differences = arrayfun(@getAngleBetweenRadians, prediction, testData.exactLabels);
results = {prediction, testData.exactLabels, differences, testData.locations};

% build confusion matrix (not very meaningful in case of regression)
amClassesRep = repmat(amountClasses, size(testData.exactLabels, 1), 1);

classPrediction = arrayfun(@getClassAssignment, prediction,           amClassesRep);
classTruth      = arrayfun(@getClassAssignment, testData.exactLabels, amClassesRep);

confMat = buildConfusionMatrix(classTruth, classPrediction, amountClasses);

end