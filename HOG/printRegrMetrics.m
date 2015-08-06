function printRegrMetrics(dataCell, description, params)

dashedLine = '---------------------------\n';
fprintf(dashedLine);
fprintf('Metrics for: %s\n', description);
fprintf(dashedLine);

% A:
% 1st row: regression estimate
% 2nd row: ground truth
% 3rd row: radian difference
A = cell2mat(dataCell(:,1:3));
radianDifferences = A(:,3);

% calculate metrics
quadPenalty = sum(arrayfun(@(x) 0.1014*x.^2, radianDifferences));
cosSimilarity = 1/size(radianDifferences, 1) * ...
    sum(arrayfun(@(x) (1+cos(x))/2, radianDifferences));

% display metrics
fprintf('quadratic penalty: %0.3f\n', quadPenalty);
fprintf('cosine similarity: %0.4f\n', cosSimilarity);
fprintf('mean squared error: %0.3f\n', sum(radianDifferences.^2));
fprintf('maximal difference: %0.3f\n', max(radianDifferences));
quantiles = [0.8, 0.9, 0.95];
for idx = 1:numel(quantiles)
    fprintf('%0.2f quantile: %0.3f\n', quantiles(idx), quantile(radianDifferences, ...
        quantiles(idx)));
end

% more detailed stacked histogram
diagramBins = 20;
xtickFlag = 3;
amountClasses = 16;
maxYAxis = size(A, 1);

[centers, classBins] = calcCenterAndBoundsForClass(amountClasses);

% split into classes
predPerClass = cell(1, amountClasses);
for j = 1:amountClasses
    if j == amountClasses
        % handle special case (for +-3.14)
        predPerClass{1, j} = A((A(:,1) >= classBins(j, 1) | A(:,1) < classBins(j, 2)),:);
    else
        predPerClass{1, j} = A((A(:,1) >= classBins(j, 1) & A(:,1) < classBins(j, 2)),:);
    end 
end

% create a histogram for every class
histogramValues = [];
figure;
for j = 1:amountClasses
    % do not show the histograms
    set(gcf, 'Visible', 'off')
    radDiffForClass = predPerClass{1, j}(:,3);
    h = histogram(radDiffForClass, diagramBins, 'BinLimits', [0 3.2]);
    histogramValues  = [histogramValues h.Values'];
end

% create stacked bar plot
legendString = 'legend(';
for j = 1:amountClasses
%     className = num2str(classBins(j,:));
    className = num2str(centers(j));
    
    legendString = strcat(legendString, '''', className, '''');
    if j ~= amountClasses
        legendString = strcat(legendString, ', ');
    else
        % add closing brackets after last element
        legendString = strcat(legendString, ')');
    end
end
figure;
bar(histogramValues, 'stacked')
eval(legendString)
set(gca, 'xticklabel', getBarLabels(diagramBins, xtickFlag))
ax = gca;
ax.Title.String = {description; sprintf('(cosine similarity: %0.4f)', cosSimilarity)};
ax.XLabel.String = 'Deviation';
% don't show all ticks
ax.XTick = [1:xtickFlag:diagramBins];
axis([0 diagramBins + 1 0 maxYAxis])

% plot images with highest error
plotDim = ceil(sqrt(params.amountImages));

[B, I] = sort(A(:,3), 'descend');
figure;
for k = 1:params.amountImages
    
    origRowNumber = I(k);
    imgLocation = dataCell{1, 4}{origRowNumber, 1};
    subplot(plotDim, plotDim, k)
    img = imread(imgLocation);
    imshow(img)
    plotTitle = strcat('dev = ', num2str(B(k), '%0.2f'));
    if k == 1
        title({description; ''; plotTitle})
    else
        title(plotTitle)
    end
    
end

end

function barLabels = getBarLabels(amountBins, flag)

allBarLabels = cell(1, amountBins);
values = linspace(0, 3.14, amountBins);
for i = 1:amountBins
    allBarLabels{1, i} = sprintf('%0.2f', values(i));
end

idxOfNecessLabels = [1:flag:amountBins];
barLabels = cell(1, length(idxOfNecessLabels));
for j = 1:length(idxOfNecessLabels)
    barLabels{1, j} = allBarLabels{1, idxOfNecessLabels(j)};
end
end