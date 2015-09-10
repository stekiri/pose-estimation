function [redTrainFeat, redTestFeat] = reduceDimensionality(...
    trainFeat, testFeat, newFeatLength, mode)
%reduceDimensionality Reduce the dimensionality.
% Reduce the dimensionality of train and test features in a uniform manner.

switch mode
    case 'pca'
        w = 1./var(trainFeat);
        [coeff, redTrainFeat, ~, ~, explained, ~] = ...
            pca(trainFeat, 'NumComponents', newFeatLength, 'VariableWeights',w);
        
        % transform coefficients so that they fulfill orthonormality
        coefforth = diag(sqrt(w))*coeff;
        
        redTestFeat = zscore(testFeat) * coefforth;
        
        fprintf('variance explained after reduction: %0.2f %%\n', sum(explained(1:newFeatLength,1)));
    case 'ppca'
        
        % [coeff,score,pcvar,mu,v,S] = ppca(trainFeat, 2);
        tic
        [pc,W,data_mean,xr,evals,percentVar]=ppca(trainFeat, 100);
        t = toc
end

end