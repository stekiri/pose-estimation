function [avgAccuracy, varOfAccuracies] = myHelperDisplayConfusionMatrix(...
    confMat, amountClasses, variant, silent)
% Display the confusion matrix in a formatted table.

% Convert confusion matrix into percentage form
confMatRel      = bsxfun(@rdivide,confMat,sum(confMat,2));
diagonal        = diag(confMatRel);
avgAccuracy     = mean(diagonal(~isnan(diagonal)));
varOfAccuracies = var(diagonal(~isnan(diagonal)));

% Do not print in comand line when in silent mode
if (~exist('silent', 'var')) || silent == false
    colHeadings = arrayfun(@(x)sprintf('%02d',x),1:amountClasses,'UniformOutput',false);
    classes = colHeadings';

    header = sprintf('%-9s','angle   |', colHeadings{:});
    output = sprintf('\n%s\n%s\n', header, repmat('-',size(header)));

    for idx = 1:length(classes)
        output = sprintf('%s%s', output, [classes{idx} '      |']);
        if strcmp(variant, 'relative')
            rowValues = sprintf('%-9.2f', confMatRel(idx,:));
        elseif strcmp(variant, 'absolute')
            rowValues = sprintf('%-9.1d', confMat(idx,:));
        end
        output = sprintf('%s%s\n', output, rowValues);
    end
    
    fprintf('%s', output);
    fprintf('\nAverage Accuracy is: %.2f\n', avgAccuracy)
end
end