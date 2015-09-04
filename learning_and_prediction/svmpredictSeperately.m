function [finalPredictions, probEstimates] = svmpredictSeperately(...
    labels, features, model, amountClasses, params)

finalPredictions = zeros(size(features,1),1);
probEstimates = [];
for f=1:size(features,1)
    currentFeature = features(f,:);
    
    singlePredictions = zeros(amountClasses);
    probabilities = zeros(amountClasses);
    
    for i=1:amountClasses
        for j=1:amountClasses
            if ~isempty(model{i,j})
                [singlePredictions(i,j), ~, probabilities(i,j)] = svmpredict(...
                    0, currentFeature, model{i,j}, '-q');
            end
        end
    end
    
    % decide on class according to the voting parameter
    switch params.voting
        case 'majority'
            % sum the votes for majority vote approach
            sumOfVotes = zeros(amountClasses, 1);
            for i=1:amountClasses
                sumOfVotes(i, 1) = sum(sum(singlePredictions == i));
            end
            
            [~, majorityVote] = max(sumOfVotes);
            finalPredictions(f,1) = majorityVote;
            
        case 'weighted_voting'
            % vote is multiplied by weight
            % (weight is higher for adjacent classes)
            helpMatrix = buildEquallyDistributedCostMatrix(amountClasses, 'exponential');
            weightMatrix = max(max(helpMatrix)) - helpMatrix + 1;
            
            weightedVotes = zeros(amountClasses,1);
            for i=1:amountClasses
                for j=1:amountClasses
                    predictedClass = singlePredictions(i,j);
                    if predictedClass ~= 0
                        weightedVotes(predictedClass,1) = ...
                            weightedVotes(predictedClass,1) + weightMatrix(i,j);
                    end
                end
            end
            
            [~, maxWeightedVote] = max(weightedVotes);
            finalPredictions(f,1) = maxWeightedVote;
            
        case 'inv_weighted_voting'
            % vote is multiplied by weight
            % (weight is lower for adjacent classes)
            weightMatrix = buildEquallyDistributedCostMatrix(amountClasses, 'exponential');
            
            weightedVotes = zeros(amountClasses,1);
            for i=1:amountClasses
                for j=1:amountClasses
                    predictedClass = singlePredictions(i,j);
                    if predictedClass ~= 0
                        weightedVotes(predictedClass,1) = ...
                            weightedVotes(predictedClass,1) + weightMatrix(i,j);
                    end
                end
            end
            
            [~, maxWeightedVote] = max(weightedVotes);
            finalPredictions(f,1) = maxWeightedVote;
            
        case 'specialized'
            sumOfSpecializedVotes = zeros(1, amountClasses);
            for i=1:amountClasses
                sumOfSpecializedVotes(1,i) = sum(singlePredictions(i,:) == i);
            end
            [~, finalPredictions(f,1)] = max(sumOfSpecializedVotes);
    end
end

end