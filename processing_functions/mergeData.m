function [trainingData, testData] = mergeData(allFoldsData, k)
%mergeData Merge data from multiple folds.
% [trainingData, testData] = mergeData(allFoldsData, k) merges the data
% from all folds except the k-th fold.
% [data] = mergeData(allFoldsData) merges the data from all folds.

% concatenate data from the folds with two alternatives

trainingData.features = [];
trainingData.exactLabels = [];
trainingData.classLabels = [];
trainingData.locations = [];
trainingData.foldOrigin = [];

switch nargin
    case 2
        % concatenate all data from the folds except the k-th fold
        for i=1:size(allFoldsData,2)
            if i ~= k
                trainingData.features = [trainingData.features; allFoldsData{1,i}.features];
                trainingData.exactLabels = [trainingData.exactLabels; allFoldsData{1,i}.exactLabels];
                trainingData.classLabels = [trainingData.classLabels; allFoldsData{1,i}.classLabels];
                trainingData.locations = [trainingData.locations; allFoldsData{1,i}.locations];
                trainingData.foldOrigin = [trainingData.foldOrigin; repmat(i, size(allFoldsData{1,i}.exactLabels))];
            end
        end
        testData = allFoldsData{1,k};
        testData.foldOrigin = repmat(k, size(allFoldsData{1,k}.exactLabels));
    case 1
        % concatenate all data from the folds
        for i=1:size(allFoldsData,2)
            trainingData.features = [trainingData.features; allFoldsData{1,i}.features];
            trainingData.exactLabels = [trainingData.exactLabels; allFoldsData{1,i}.exactLabels];
            trainingData.classLabels = [trainingData.classLabels; allFoldsData{1,i}.classLabels];
            trainingData.locations = [trainingData.locations; allFoldsData{1,i}.locations];
            trainingData.foldOrigin = [trainingData.foldOrigin; repmat(i, size(allFoldsData{1,i}.exactLabels))];
        end
        testData = [];
end
end