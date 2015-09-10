function [modelC, modelR] = trainCombClassifRegrModel(trainData, numClasses, params)
%trainCombClassifRegrModel Train a classification and regression model.
% [modelC, modelR] = trainCombClassifRegrModel(trainData, numClasses, params)
% trains a classification and a regression model. Later these two models
% are used in a combined manner to determine the final output.

if params.threshold == 0
    % perform classification only
    modelC = trainClassifModel(trainData, params, numClasses);
    modelR = [];
    
elseif params.threshold >= 3.14
    % perform regression only
    modelR = trainRegrModel(trainData, params);
    modelC = [];
    
else
    % perform classification and regression
    modelC = trainClassifModel(trainData, params, numClasses);
    modelR = trainRegrModel(trainData, params);
    
end
end

function model = trainClassifModel(trainData, params, numClasses)

switch params.classifLibrary
    case 'matlab'
        
        [~, ~, S.ClassNames] = calcCenterAndBoundsForClass(numClasses);
        S.ClassNames = char(S.ClassNames);
        S.ClassificationCosts = buildEquallyDistributedCostMatrix(16, 'exponential');
        
        learner = templateSVM('KernelFunction', params.kernel);
        
        % fitcecoc uses SVM learners and a 'One-vs-One' encoding scheme.
        model = fitcecoc(trainData.features, trainData.classLabels, ...
            'Coding', params.codingCl, 'Learners', learner, 'Cost', S);
        
    case 'libsvm'
        
        trainData.classLblsCell   = cellstr(trainData.classLabels);
        trainData.classLblsDouble = cellfun(@getClassLabelAsDouble, trainData.classLblsCell);
        
        switch params.coding
            case 'onevsall'
                model = ovrtrain(trainData.classLblsDouble, double(trainData.features), ...
                    buildLibsvmCmd(params));
                
            case 'onevsone'
                model = svmtrain(trainData.classLblsDouble, double(trainData.features), ...
                    buildLibsvmCmd(params));
                
            case 'onevsone_custom'
                model = svmtrainSeperately(trainData.classLblsDouble, ...
                    double(trainData.features), params, numClasses);
                
        end
end
end

function model = trainRegrModel(trainData, params)

switch params.regrLibrary
    case 'matlab'
        % train a simple regression tree
        model = fitrtree(trainData.features, trainData.exactLabels);
        
    case 'libsvm'
        % train with libsvm regression
        model = svmtrain(trainData.exactLabels, double(trainData.features), ...
            params.libsvmRegrCmd);
        
end
end

function classDouble = getClassLabelAsDouble(classString)

splittedString = strsplit(classString, '_');
classDouble = str2double(splittedString(1));

end

function [model] = ovrtrain(y, x, cmd)
% Source: www.csie.ntu.edu.tw/~cjlin/libsvmtools/ovr_multiclass/ovrtrain.m

labelSet = unique(y);
labelSetSize = length(labelSet);
models = cell(labelSetSize,1);

for i=1:labelSetSize
    models{i} = svmtrain(double(y == labelSet(i)), x, cmd);
end

model = struct('models', {models}, 'labelSet', labelSet);
end