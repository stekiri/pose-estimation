function gridResults = performCrossValidation(allFoldsData, processParams, predParams, ...
    gridParams, backupDir)

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
    
    currentC = num2str(paramList{p}.C);
    currentG = num2str(paramList{p}.gamma);
    
    switch predParams.kernel
        case 'linear'
            fprintf('Grid values: C = %s\n' , currentC);
            predParams.svmParameter.C = currentC;
        case {'polynomial', 'rbf'}
            fprintf('Grid values: C = %s , gamma = %s\n', currentC, currentG);
            predParams.svmParameter.C = currentC;
            predParams.svmParameter.gamma = currentG;
    end
    
    cvMetrics       = zeros(1, processParams.folds);
    cvTanhMetrics   = zeros(1, processParams.folds);
    cvResults       = cell (1, processParams.folds);
    avgAccurracies  = zeros(1, processParams.folds);
    varOfAccur      = zeros(1, processParams.folds);
    
    tic
    for k=1:processParams.folds
        fprintf('Cross-validation for fold #%d ...\n', k);
        % merge all folds except k-th fold
        [trainD, testD] = mergeData(allFoldsData, k);
        
        % reduce dimensionality if desired
        if predParams.reduceDimensionality == true
            [trainD.features, testD.features] = reduceDimensionality(...
                trainD.features, testD.features, predParams.reducedFeatLength, ...
                predParams.reductionMode);
        end
        
        % learn the models
        [cv.modelC, cv.modelR] = ...
            trainCombClassifRegrModel(trainD, processParams.classes, predParams);
        % predict test data with learned models
        [prediction, cv.probEstim, cv.plotTitle] = ...
            testCombClassifRegrModel(...
            cv.modelC, cv.modelR, testD, processParams.classes, predParams);
        % calculate differences between truth and prediction & confusion matrix
        [cv.results, cv.confMat] = calcPredictionResults(...
            prediction, testD, processParams.classes);
        
        % model can be large and is not always needed to be saved
        if predParams.saveModel == false
            cv.modelC = [];
            cv.modelR = [];
        end
        
        % include fold number into plot title
        cv.plotTitle = sprintf('%s -- cv%d', cv.plotTitle, k);
        
        % calculate metric
        helpVec = cell2mat(cv.results(:,3));
        evalMetric = 1/size(helpVec, 1) * sum(arrayfun(@(x) (1+cos(x))/2, helpVec))
        tanhMetric = 1/size(helpVec, 1) * sum(arrayfun(@(x) 1 - tanh(x), helpVec))
        
        % save metric
        cvMetrics(1,k) = evalMetric;
        cvTanhMetrics(1,k) = tanhMetric;
        cvResults{1,k} = cv;
        [avgAccurracies(1,k), varOfAccur(1,k)] = myHelperDisplayConfusionMatrix(...
            cv.confMat, processParams.classes, 'absolute', true);
        
        % save backup file on hdd
        fileName = sprintf('fold%02d.mat', k);
        save(fullfile(backupFolder, fileName), 'cv');
    end
    t = toc;
    fprintf('average evaluation metric: %0.6f\n', mean(cvMetrics));
    fprintf('average tanh metric: %0.6f\n', mean(cvTanhMetrics));
    fprintf('computation time: %0.1f min\n', t/60);
    
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
                        'params', {predParams});
                    
    % save backup file on hdd
    currResult = gridResults{1,p};
	fileName = sprintf('gridResults%02d.mat', p);
	save(fullfile(backupFolder, fileName), 'currResult');
    
end

% save backup file on hdd
fileName = sprintf('allResults.mat');
save(fullfile(backupFolder, fileName), 'gridResults');

end