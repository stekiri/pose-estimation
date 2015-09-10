function [gridResults, bestSVMParams] = performCrossValidation(...
    allFoldsData, processParams, predParams, gridParams, backupDir)
%performCrossValidation Executes the cross-validation.
% [gridResults, bestSVMParams] = performCrossValidation(allFoldsData, processParams, predParams, gridParams, backupDir)
% cross-validates the results for a given set of SVM parameters. The
% metrics are calculated from the results and all the results are saved on
% the HDD. Furthermore, the best SVM parameters are returned.

% initialize best results
bestResults = 0;
bestSVMParams = [];

% assign broadcast variables to temporary variables
numClasses  = processParams.classes;
numFolds    = processParams.folds;
kernel      = predParams.kernel;

k = 1;
paramList = cell(1,length(gridParams.C)*length(gridParams.gamma));
for l=1:length(gridParams.C)
    for m=1:length(gridParams.gamma)
        paramList{k}.C      = gridParams.C(l);
        paramList{k}.gamma  = gridParams.gamma(m);
        k = k + 1;
    end
end

% time stamp to create backup folder
dateTime = fix(clock);
timeStamp = sprintf('%04d_%02d_%02d-%02d_%02d_%02d', dateTime);
backupFolder = fullfile(backupDir, timeStamp);
mkdir(backupFolder);

gridResults = cell(1, length(paramList));
for p=1:length(paramList)
    % svm parameter values
    currentC = num2str(paramList{p}.C);
    currentG = num2str(paramList{p}.gamma);
    
    switch kernel
        case 'linear'
            resultLine = sprintf('Grid values: C = %s\n' , currentC);
            subStruct = struct('C', currentC);
        case {'polynomial', 'rbf'}
            resultLine = sprintf('Grid values: C = %s , gamma = %s\n', currentC, currentG);
            subStruct = struct('C', currentC, 'gamma', currentG);
    end
    % save the svm parameters in a structure
    predParamsSVM = struct('svmParameter', subStruct);
    % merge parameter structure objects and overwrite the svmParameter dummy fields in
    % predParams by the values from predParamsSVM
    updatedPredParams = setstructfields(predParams, predParamsSVM);
    
    cvMetrics       = zeros(1, numFolds);
    cvTanhMetrics   = zeros(1, numFolds);
    cvResults       = cell (1, numFolds);
    avgAccurracies  = zeros(1, numFolds);
    varOfAccur      = zeros(1, numFolds);
    
    tic
    for k=1:numFolds
        % merge all folds except k-th fold
        [trainD, testD] = mergeData(allFoldsData, k);
        
        % reduce dimensionality if desired
        if updatedPredParams.reduceDimensionality == true
            [trainD.features, testD.features] = reduceDimensionality(...
                trainD.features, testD.features, updatedPredParams.reducedFeatLength, ...
                updatedPredParams.reductionMode);
        end
        
        % learn the models
        [modelC, modelR] = ...
            trainCombClassifRegrModel(trainD, numClasses, updatedPredParams);
        % predict test data with learned models
        [prediction, probEstim, plotTitle] = ...
            predictCombClassifRegrModel(...
            modelC, modelR, testD, numClasses, updatedPredParams);
        % calculate differences between truth and prediction & confusion matrix
        [results, confMat] = calcPredictionResults(...
            prediction, testD, numClasses);
        
        % models can be large and do not always have to be saved
        if updatedPredParams.saveModel == false
            modelC = [];
            modelR = [];
        end
        
        % include fold number into plot title
        plotTitle = sprintf('%s -- cv%d', plotTitle, k);
        
        % calculate metric
        helpVec = cell2mat(results(:,3));
        evalMetric = 1/size(helpVec, 1) * sum(arrayfun(@(x) (1+cos(x))/2, helpVec));
        tanhMetric = 1/size(helpVec, 1) * sum(arrayfun(@(x) 1 - tanh(x), helpVec));
        
        cv = struct(...
            'modelC',       {modelC},...
            'modelR',       {modelR},...
            'probEstim',    {probEstim},...
            'plotTitle',    {plotTitle},...
            'results',      {results},...
            'confMat',      {confMat});
        
        % save metric
        cvMetrics(1,k) = evalMetric;
        cvTanhMetrics(1,k) = tanhMetric;
        cvResults{1,k} = cv;
        [avgAccurracies(1,k), varOfAccur(1,k)] = myHelperDisplayConfusionMatrix(...
            confMat, numClasses, 'absolute', true);
        
        % save backup file on hdd
        fileName = sprintf('fold%02d.mat', k);
        save(fullfile(backupFolder, fileName), 'cv');
    end
    t = toc;
    fprintf('%saverage cosine metric: %0.6f\naverage tanh metric: %0.6f\ncomputation time: %0.1f min\n',...
        resultLine, mean(cvMetrics), mean(cvTanhMetrics), t/60);
    
    gridResults{1,p} = struct(...
                        'avgMetric', {mean(cvMetrics)},...
                        'avgTanhMetric', {mean(cvTanhMetrics)},...
                        'avgVariance', {mean(varOfAccur)},...
                        'calcTime', {t},...
                        'cvMetrics', {cvMetrics},...
                        'cvTanhMetrics', {cvTanhMetrics},...
                        'cvResults', {cvResults},...
                        'avgAccuracies', {avgAccurracies},...
                        'varOfAccur', {varOfAccur},...
                        'C', {currentC},...
                        'gamma', {currentG},...
                        'params', {updatedPredParams});
                    
    % save backup file on hdd
    currResult = gridResults{1,p};
	fileName = sprintf('gridResults%02d.mat', p);
	save(fullfile(backupFolder, fileName), 'currResult');
    
    % set new best parameters if results are better than previous ones 
    if mean(cvMetrics) > bestResults
        bestResults = mean(cvMetrics);
        bestSVMParams = paramList{p};
    end
    
end

% save backup file on hdd
fileName = sprintf('allResults.mat');
save(fullfile(backupFolder, fileName), 'gridResults');

end
