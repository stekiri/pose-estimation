function [allTruClass, allPredClass] = createClassMembershipPlot(allResults, processParams, params)
%createClassMembershipPlot Create a plot with the amount of class memberships.
% [allTruClass, allPredClass] = createClassMembershipPlot(allResults, processParams, params)
% creates a plot which shows how many predictions and how many actual
% values there are per class.

allPredClass = 0;
allTruClass  = 0;

for cvNum = 1:processParams.folds
    currentResults = allResults.cvResults{1,cvNum}.results;
    
    % get class memberships for every truth and prediction value
    classesRep = repmat(16, length(currentResults{1,1}), 1);
    tru  = arrayfun(@getClassAssignment, currentResults{1,2}, classesRep);
    pred = arrayfun(@getClassAssignment, currentResults{1,1}, classesRep);
    
    % initialize
    truClass  = zeros(processParams.classes,1);
    predClass = zeros(processParams.classes,1);
    
    % add up class membership for single fold
    for i=1:processParams.classes
        truClass(i,1)  = sum(tru  == i);
        predClass(i,1) = sum(pred == i);
    end
    
    % aggregate class membership for all folds
    allPredClass = allPredClass + predClass;
    allTruClass  = allTruClass + truClass;
    
    if params.singleFolds
        % create class balance plots for every single fold
        figure;
        bar([truClass predClass])
        xlim([0.5 processParams.classes + 0.5])
        title(['fold ', num2str(cvNum)])
        legend('truth', 'prediction')
    end
    
end

if params.allFolds
    % create class imbalance plot for aggregated data from all folds
    figure;
    bar([allTruClass allPredClass])
    xlim([0.5 processParams.classes + 0.5])
    title('class membership -- all folds')
    legend('truth', 'prediction')
end

end
