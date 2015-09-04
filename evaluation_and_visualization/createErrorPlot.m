function binSums = createErrorPlot(dataCell, params)

% A:
% 1st row: regression estimate
% 2nd row: ground truth
% 3rd row: radian difference
A = cell2mat(dataCell(:,1:3));

maxYAxis = size(A, 1);

switch params.mode
    case 'classes'
        distinctions = params.classes;
        
        [centers, classBins] = calcCenterAndBoundsForClass(params.classes);
        
        % split into classes -> to which class do the images actually belong to (ground
        % truth)
        belonging = cell(1, params.classes);
        for j = 1:params.classes
            if j == params.classes
                % handle special case (for +-3.14)
                belonging{1, j} = A((A(:,2) >= classBins(j, 1) | A(:,2) < classBins(j, 2)),:);
            else
                belonging{1, j} = A((A(:,2) >= classBins(j, 1) & A(:,2) < classBins(j, 2)),:);
            end
        end
        
        % build legend string
        legendString = 'legend(';
        for j = 1:params.classes
            %     className = num2str(classBins(j,:));
            className = sprintf('%+0.2f', centers(j));
            
            legendString = strcat(legendString, '''', className, '''');
            if j ~= params.classes
                legendString = strcat(legendString, ', ');
            else
                % add closing brackets after last element
                legendString = strcat(legendString, ')');
            end
        end
        
    case 'difficulties'
        
        difficultyModes = {1, 2, 3}; % easy, moderate, hard
        distinctions = size(difficultyModes, 2);
        
        % extract image properties
        locations = dataCell{:,4};
        [~, ~, ~, occlusions, truncations, heights, ~] = ...
            cellfun(@getImageProperties, locations, 'UniformOutput', false);
        
        occlusions  = cell2mat(occlusions);
        truncations = cell2mat(truncations);
        heights     = cell2mat(heights);
        
        [~, difficultyNumbers] = arrayfun(@getImageDifficulty, occlusions, ...
            truncations, heights, 'UniformOutput', false);
        
        difficultyNumbers = cell2mat(difficultyNumbers);
        
        A = [A, difficultyNumbers];
        
        % sort each difficulty into a cell
        belonging = cell(1, distinctions);
        for j=1:distinctions;
            belonging{1, j} = A(A(:,4) == difficultyModes{1, j},:);
        end
        
        legendString = 'legend(''easy'', ''moderate'', ''hard'')';
end

% sum up all the values per class/difficulty
binSums = zeros(params.diagramBins,distinctions);
for j = 1:distinctions
    
    % get deviations for the current distinction
    radDiffForClass = belonging{1, j}(:,3);
    
    binAssignments = arrayfun(@getBinAssignment, radDiffForClass, ...
        repmat(params.diagramBins, size(radDiffForClass,1), 1));
    
    amountInBin = zeros(params.diagramBins,1);
    for b=1:params.diagramBins
        amountInBin(b,1) = sum(binAssignments == b);
    end
    binSums(:,j) = amountInBin;
end

% calculate evaluation metrics:
diffVec = A(:,3);
evalMetric = 1/size(diffVec, 1) * sum(arrayfun(@(x) (1+cos(x))/2, diffVec));
tanhMetric = 1/size(diffVec, 1) * sum(arrayfun(@(x) (1-tanh(x)), diffVec));

figure;
bar(binSums, 'stacked');
eval(legendString)
set(gca, 'xticklabel', getBarLabels(params.diagramBins, params.xtickFlag))
ax = gca;
ax.Title.String = {...
                    params.description; ...
                    sprintf('(cosine metric: %0.3f)', evalMetric); ...
                    sprintf('(tanh metric: %0.3f)', tanhMetric)};

ax.XLabel.String = 'Deviation';
% don't show all ticks
ax.XTick = 1:params.xtickFlag:params.diagramBins;
axis([0 params.diagramBins + 1 0 maxYAxis])

if params.print == true
    saveas(f, fullfile(params.saveLocation, sprintf('%s_%s.png', params.plotName, ...
        params.mode)));
end

end

function barLabels = getBarLabels(amountBins, flag)

allBarLabels = cell(1, amountBins);
values = linspace(0, 3.14, amountBins + 1);
for i = 1:amountBins
    allBarLabels{1, i} = sprintf('%0.2f', values(i+1));
end

idxOfNecessLabels = 1:flag:amountBins;
barLabels = cell(1, length(idxOfNecessLabels));
for j = 1:length(idxOfNecessLabels)
    barLabels{1, j} = allBarLabels{1, idxOfNecessLabels(j)};
end
end