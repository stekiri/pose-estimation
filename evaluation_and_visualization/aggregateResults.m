function aggregatedResults = aggregateResults(allResults, folds)
%aggregateResults Aggregate cross-validated results.
% aggregatedResults = aggregateResults(allResults, folds) concatenates the
% results from the single folds produced by the cross-validation process.
% The aggregated results can be used to evaluate and visualize the
% performance over all folds.

aggregatedResults = cell(1,5);

for cvNum = 1:folds
    currentResults = allResults.cvResults{1,cvNum}.results;
    
    % aggregate truth and prediction data for aggregated error plot
    for i=1:4
        aggregatedResults{1,i} = [aggregatedResults{1,i}; currentResults{1,i}];
    end
    
    % include fold origin as additional information in 5th column
    aggregatedResults{1,5} = [aggregatedResults{1,5};...
        repmat(cvNum, length(currentResults{1,1}),1)];
    
end
end
