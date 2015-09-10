function [avgAccuracy, varOfAccuracies] = myHelperDisplayConfusionMatrix(...
    confMat, numClasses, variant, silent)
%myHelperDisplayConfusionMatrix Display the confusion matrix.
% [avgAccuracy, varOfAccuracies] = myHelperDisplayConfusionMatrix(confMat, numClasses, variant, silent)
% displays the confusion matrix as a formatted table.
% Input:
% - confMat: the pre-computed confusion matrix.
% - numClasses: the number of unique classes.
% - varian: 'relative' or 'absolute' values for the output.
% - silent: table is not printed in command line when set to 'true'.


% Convert confusion matrix into percentage form
confMatRel      = bsxfun(@rdivide,confMat,sum(confMat,2));
diagonal        = diag(confMatRel);
avgAccuracy     = mean(diagonal(~isnan(diagonal)));
varOfAccuracies = var(diagonal(~isnan(diagonal)));

% Do not print in command line when in silent mode
if (~exist('silent', 'var')) || silent == false
    colHeadings = arrayfun(@(x)sprintf('%02d',x),1:numClasses,'UniformOutput',false);
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
