function printResultMetrics(dataCell, params)
%printResultMetrics Print the results metrics.
% printResultMetrics(dataCell, params) prints the metrics containing the
% results on the command line.

dashedLine = '---------------------------\n';
fprintf(dashedLine);
fprintf('Metrics for: %s\n', params.description);
fprintf(dashedLine);

% A:
% 1st row: regression estimate
% 2nd row: ground truth
% 3rd row: radian difference
A = cell2mat(dataCell(:,1:3));
radianDifferences = A(:,3);

% calculate metrics
quadPenalty = sum(arrayfun(@(x) 0.1014*x.^2, radianDifferences));
evalMetric = 1/size(radianDifferences, 1) * ...
    sum(arrayfun(@(x) (1+cos(x))/2, radianDifferences));

% display metrics
fprintf('evaluation metric: %0.4f\n', evalMetric);
fprintf('quadratic penalty: %0.3f\n', quadPenalty);
fprintf('mean squared error: %0.3f\n', sum(radianDifferences.^2));
fprintf('maximal difference: %0.3f\n', max(radianDifferences));
quantiles = [0.8, 0.9, 0.95];
for idx = 1:numel(quantiles)
    fprintf('%0.2f quantile: %0.3f\n', quantiles(idx), quantile(radianDifferences, ...
        quantiles(idx)));
end
end
