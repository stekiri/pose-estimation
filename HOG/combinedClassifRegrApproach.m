function [results, plotTitle, confMat, modelC, modelR, probEstimates] = ...
    combinedClassifRegrApproach(...
    trainData, testData, amountClasses, params)

if params.threshold == 0
    % perform classification only
    [prediction, modelC, probEstimates] = performClassification(trainData, testData, params, amountClasses);
    plotTitle = 'classification';
    modelR = [];
    
elseif params.threshold >= 3.14
    % perform regression only
    [prediction, modelR] = performRegression(trainData, testData, params);
    plotTitle = 'regression';
    modelC = [];
    
else
    % perform classification and regression
    [clPredDouble, modelC]  = performClassification(trainData, testData, params);
    [regPrediction, modelR] = performRegression(    trainData, testData, params);
    
    % perform voting
    fprintf('Perform Voting ... ');
    % threshold is subject to optimization; dependent on image set size? optValue = [0.2, 0.3]
    thresholds = repmat(params.threshold, size(regPrediction, 1), 1);
    prediction = arrayfun(@clOrRegVoting, clPredDouble, regPrediction, thresholds);
    fprintf(' DONE!\n');
    
    plotTitle = sprintf('classification + regression, threshold = %0.2f', params.threshold);
end

differences = arrayfun(@getAngleBetweenRadians, prediction, testData.exactLabels);
results = {prediction, testData.exactLabels, differences, testData.locations};

% build confusion matrix (not very meaningful in case of regression)
amClassesRep = repmat(amountClasses, size(testData.exactLabels, 1), 1);

classPrediction = arrayfun(@getClassAssignment, prediction,           amClassesRep);
classTruth      = arrayfun(@getClassAssignment, testData.exactLabels, amClassesRep);

confMat = buildConfusionMatrix(classTruth, classPrediction, amountClasses);

end

function [prediction, model, probEstimates] = performClassification(...
    trainData, testData, params, amountClasses)

% fprintf('Perform Classification ... ');
switch params.library
    case 'matlab'
        
        [~, ~, S.ClassNames] = calcCenterAndBoundsForClass(amountClasses);
        S.ClassNames = char(S.ClassNames)
        S.ClassificationCosts = buildEquallyDistributedCostMatrix(16, 'exponential')
        
        learner = templateSVM('KernelFunction', params.kernel);
        
        % fitcecoc uses SVM learners and a 'One-vs-One' encoding scheme.
        model = fitcecoc(trainData.features, trainData.classLabels, ...
            'Coding', params.codingCl, 'Learners', learner, 'Cost', S);
        
        % make class predictions using the test features.
        prediction = predict(model, testData.features);
        
        % conversion of labels from char to double using the center of the class as prediction
        % value
        prediction = char2double(prediction);
        
    case 'libsvm'
        
        trainData.classLblsCell   = cellstr(trainData.classLabels);
        trainData.classLblsDouble = cellfun(@getClassLabelAsDouble, trainData.classLblsCell);
        
        testData.classLblsCell   = cellstr(testData.classLabels);
        testData.classLblsDouble = cellfun(@getClassLabelAsDouble, testData.classLblsCell);
        
        dummyLabels = zeros(size(testData.features,1), 1);
        switch params.coding
            case 'onevsall'
                model = ovrtrain(trainData.classLblsDouble, double(trainData.features), ...
                    buildLibsvmCmd(params));
                predictionDouble = ovrpredict(dummyLabels, double(testData.features), ...
                    model, '-q');
                
            case 'onevsone'
                model = svmtrain(trainData.classLblsDouble, double(trainData.features), ...
                    buildLibsvmCmd(params));
                [predictionDouble, ~, probEstimates] = svmpredict(dummyLabels, ...
                    double(testData.features), model, '-q');
                
            case 'onevsone_custom'
                fprintf('training\n')
                model = svmtrainSeperately(trainData.classLblsDouble, ...
                    double(trainData.features), params, amountClasses);
                fprintf('prediction\n')
                [predictionDouble, probEstimates] = svmpredictSeperately(...
                    dummyLabels, double(testData.features), model, ...
                    amountClasses, params);
        end
        
        amountClassesRep = repmat(amountClasses, size(predictionDouble,1), 1);
        predictionCell = arrayfun(@getClassLabelAsString, predictionDouble, amountClassesRep, ...
            'UniformOutput', false);
        prediction = char2double(char(predictionCell));
        
end

if params.saveModel == false
    model = [];
end

% fprintf(' DONE!\n');
end

function [prediction, model] = performRegression(trainData, testData, params)

fprintf('Perform Regression ... ');
switch params.library
    case 'matlab'
        
        % train a simple regression tree
        model = fitrtree(trainData.features, trainData.exactLabels);
        
        % predict exact values with regression tree
        prediction = predict(model, testData.features);
        
    case 'libsvm'
        
        model = svmtrain(trainData.exactLabels, double(trainData.features), ...
            params.libsvmRegrCmd);
        prediction = svmpredict(testData.exactLabels, ...
            double(testData.features), model, '-q');
        
end

if params.saveModel == false
    model = [];
end

fprintf(' DONE!\n');
end

function classDouble = getClassLabelAsDouble(classString)

splittedString = strsplit(classString, '_');
classDouble = str2double(splittedString(1));

end

function classString = getClassLabelAsString(classDouble, amountClasses)

[centers, ~] = calcCenterAndBoundsForClass(amountClasses);
classString = sprintf('%02d_%+0.2f', classDouble, centers(classDouble));

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

function [pred, ac, decv] = ovrpredict(y, x, model)
% Source: www.csie.ntu.edu.tw/~cjlin/libsvmtools/ovr_multiclass/ovrpredict.m

labelSet = model.labelSet;
labelSetSize = length(labelSet);
models = model.models;
decv= zeros(size(y, 1), labelSetSize);

for i=1:labelSetSize
    [l,a,d] = svmpredict(double(y == labelSet(i)), x, models{i});
    decv(:, i) = d * (2 * models{i}.Label(1) - 1);
end
[tmp,pred] = max(decv, [], 2);
pred = labelSet(pred);
ac = sum(y==pred) / size(x, 1);
end

function [ac] = get_cv_ac(y,x,param,nr_fold)
% Source: www.csie.ntu.edu.tw/~cjlin/libsvmtools/ovr_multiclass/get_cv_ac.m

len=length(y);
ac = 0;
rand_ind = randperm(len);
for i=1:nr_fold % Cross training : folding
    test_ind=rand_ind([floor((i-1)*len/nr_fold)+1:floor(i*len/nr_fold)]');
    train_ind = [1:len]';
    train_ind(test_ind) = [];
    model = ovrtrain(y(train_ind),x(train_ind,:),param);
    [pred,a,decv] = ovrpredict(y(test_ind),x(test_ind,:),model);
    ac = ac + sum(y(test_ind)==pred);
end
ac = ac / len;
fprintf('Cross-validation Accuracy = %g%%\n', ac * 100);
end