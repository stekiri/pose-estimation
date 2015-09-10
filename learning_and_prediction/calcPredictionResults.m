function [results, confMat] = calcPredictionResults(prediction, testData, numClasses)
%calcPredictionResults Calculate the prediction results.
% [results, confMat] = calcPredictionResults(prediction, testData, numClasses)
% returns the results of the prediction including not only the prediction
% but also the exact labels, the differences between prediction and exact
% labels, and the locations of the images. The function also computes and
% returns the confusion matrix.

differences = arrayfun(@getAngleBetweenRadians, prediction, testData.exactLabels);
results = {prediction, testData.exactLabels, differences, testData.locations};

% build confusion matrix (not very meaningful in case of regression)
amClassesRep = repmat(numClasses, size(testData.exactLabels, 1), 1);

classPrediction = arrayfun(@getClassAssignment, prediction,           amClassesRep);
classTruth      = arrayfun(@getClassAssignment, testData.exactLabels, amClassesRep);

confMat = buildConfusionMatrix(classTruth, classPrediction, numClasses);

end