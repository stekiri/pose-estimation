function [prediction, probEstimates, plotTitle] = ...
    predictCombClassifRegrModel(modelC, modelR, testData, numClasses, params)
%predictCombClassifRegrModel Predict using classification and regression model.
% [prediction, probEstimates, plotTitle] = predictCombClassifRegrModel(modelC, modelR, testData, numClasses, params)
% returns a prediction by using a classification and regression model.
% Decision which model is used depends on a predefined threshold.

if params.threshold == 0
    % perform classification only
    [prediction, probEstimates] = testClassifModel(...
        modelC, testData.features, params, numClasses);
    plotTitle = 'classification';
    
elseif params.threshold >= 3.14
    % perform regression only
    [prediction, probEstimates] = testRegrModel(modelR, testData.features, params);
    plotTitle = 'regression';
    
else
    % perform classification and regression
    [clPredDouble, probEstimates] = testClassifModel(...
        modelC, testData.features, params, numClasses);
    [regPrediction] = testRegrModel(modelR, testData.features, params);
    
    % perform voting
    thresholds = repmat(params.threshold, size(regPrediction, 1), 1);
    prediction = arrayfun(@clOrRegVoting, clPredDouble, regPrediction, thresholds);
    
    plotTitle = sprintf('classification + regression, threshold = %0.2f', params.threshold);
end
end

function [prediction, probEstimates] = testClassifModel(...
    model, testFeatures, params, numClasses)

switch params.classifLibrary
    case 'matlab'
        % make class predictions using the test features.
        prediction = predict(model, testFeatures);
        
        % conversion of labels from char to double using the center of the class as prediction
        % value
        prediction = char2double(prediction);
        
    case 'libsvm'
        dummyLabels = zeros(size(testFeatures,1), 1);
        
        switch params.coding
            case 'onevsall'
                [predictionDouble, ~, probEstimates] = ovrpredict(...
                    dummyLabels, double(testFeatures), model, '-q');
                
            case 'onevsone'
                [predictionDouble, ~, probEstimates] = svmpredict(...
                    dummyLabels, double(testFeatures), model, '-q');
                
            case 'onevsone_custom'
                [predictionDouble, probEstimates] = svmpredictSeperately(...
                    dummyLabels, double(testFeatures), model, ...
                    numClasses, params);
        end
        
        numClassesRep = repmat(numClasses, size(predictionDouble,1), 1);
        predictionCell = arrayfun(@getClassLabelAsString, predictionDouble, numClassesRep, ...
            'UniformOutput', false);
        prediction = char2double(char(predictionCell));
        
end
end

function [prediction, probEstimates] = testRegrModel(model, testFeatures, params)

probEstimates = [];

switch params.regrLibrary
    case 'matlab'        
        % predict exact values with regression tree
        prediction = predict(model, testFeatures);
        
    case 'libsvm'
        dummyLabels = zeros(size(testFeatures,1), 1);
        % predict with learned libsvm regression model
        prediction = svmpredict(dummyLabels, ...
            double(testFeatures), model, '-q');
        
end
end

function classString = getClassLabelAsString(classDouble, numClasses)

[centers, ~] = calcCenterAndBoundsForClass(numClasses);
classString = sprintf('%02d_%+0.2f', classDouble, centers(classDouble));

end

function [pred, ac, decv] = ovrpredict(y, x, model, libsvmCmd)
% Source: www.csie.ntu.edu.tw/~cjlin/libsvmtools/ovr_multiclass/ovrpredict.m

labelSet = model.labelSet;
labelSetSize = length(labelSet);
models = model.models;
decv= zeros(size(y, 1), labelSetSize);

for i=1:labelSetSize
    [l,a,d] = svmpredict(double(y == labelSet(i)), x, models{i}, libsvmCmd);
    decv(:, i) = d * (2 * models{i}.Label(1) - 1);
end
[tmp,pred] = max(decv, [], 2);
pred = labelSet(pred);
ac = sum(y==pred) / size(x, 1);
end