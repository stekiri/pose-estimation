function model = svmtrainSeperately(labels, features, params, amountClasses)
%svmtrainSeperately Predict with seperately trained SVM classifiers.
% model = svmtrainSeperately(labels, features, params, amountClasses)
% trains all possible combinations of SVM classifiers, e.g., 1vs2 AND 2vs1.
% It returns a cell which includes all models

% initialize
model = cell(amountClasses);
% compute cost matrix for penalization
costMatrix = buildEquallyDistributedCostMatrix(16, 'exponential');

for i=1:amountClasses
    for j=1:amountClasses
        switch params.mode
            case 'all'
                % build all one-vs-one classifiers (1vs2 and 2vs1, etc.)
                if i ~= j
                    
%                     % change the weights to train specifically well class predictors
%                     % 1vs2 only predicts 1 when it is really sure that instance is 1
%                     % 2vs1 only predicts 2 when it is really sure that instance is 2
%                     tempParams = params;
%                     tempParams.classWeights = zeros(1, amountClasses);
% %                     tempParams.classWeights(1,i) = costMatrix(i,j);
% %                     tempParams.classWeights(1,j) = 1;
%                     tempParams.classWeights(1,i) = params.classWeights(1,i) * costMatrix(i,j);
%                     tempParams.classWeights(1,j) = params.classWeights(1,j) * 1;
%                     
%                     model{i,j} = trainSingleModel(labels, features, ...
%                         buildLibsvmCmd(tempParams), i, j);
                    % change the weights to train specifically well class predictors
                    % 1vs2 only predicts 1 when it is really sure that instance is 1
                    % 2vs1 only predicts 2 when it is really sure that instance is 2
                    
                    additionalParam.i = i;
                    additionalParam.j = j;
                    additionalParam.factor = costMatrix(i,j);
                    
                    model{i,j} = trainSingleModel(labels, features, ...
                        buildLibsvmCmd(params, additionalParam), i, j);
                end
                
            case 'reduced'
                % build only k*(k-1)/2 one-vs-one classifiers (not 1vs2 and 2vs1, etc.)
                if (i < j)
                    model{i,j} = trainSingleModel(labels, features, ...
                        buildLibsvmCmd(params), i, j);
                end
        end
    end
end

end

function model = trainSingleModel(labels, features, libsvmCmd, i, j)

posFeatures = features(labels == i,:);
negFeatures = features(labels == j,:);
allFeatures = [posFeatures; negFeatures];

posLabels = repmat(i, size(posFeatures, 1), 1);
negLabels = repmat(j, size(negFeatures, 1), 1);
allLabels = [posLabels; negLabels];

model = svmtrain(allLabels, allFeatures, libsvmCmd);

end
