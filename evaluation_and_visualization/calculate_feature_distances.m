% Script to compute the distances in feature space between the all images.
% Different variants with varying computation time.

% features = allFoldsData{1,1}.features;
% 
% featDistances = zeros(size(features,1));
% 
% %% obsolete?
% for i=1:size(features, 1)
%     x = features(i,:);
%     for j=1:size(features,1)
%         y = features(j,:);
%         featDistances(i,j) = sqrt(sum((x-y).^2));
%     end
% end
% %%
% 
% 
% [maxValue, maxIdx] = max(allResults{1,1}.cvResults{1,1}.probEstim, [], 2);


%% 1st version (slow)

[allData, ~] = mergeData(allFoldsData);

features = allData.features;

featDistances = zeros(size(features,1));

tic
for i=1:size(features, 1)
    fprintf('i = %d\n', i);
    x = features(i,:);
    for j=1:size(features,1)
        y = features(j,:);
        % calculate only if symmetric distance hasn't been calculated before
        if featDistances(i,j) == 0
            % calculate distance only if the features originates from a different fold
            if allData.foldOrigin(i,1) ~= allData.foldOrigin(j,1)
                distance = sqrt(sum((x-y).^2));
            else
                distance = NaN;
            end
            featDistances(i,j) = distance;
            featDistances(j,i) = distance;
        end
    end
end
t = toc;
fprintf('time: %f', t);


%% 2nd version (faster - time: 1124.938280)
tic
featDistances2 = zeros(size(features,1));

for i=1:size(features,1)
    fprintf('i = %d\n',i);
    currFeat = features(i,:);
    otherFeat = features;
    
    currFeatCell = mat2cell(currFeat, 1, size(currFeat,2));
    currFeatCellRep = repmat(currFeatCell, size(otherFeat, 1), 1);
    
    otherFeatCell = mat2cell(otherFeat, ones(1, size(otherFeat,1)), size(otherFeat,2));
    
    featDistances2(i,:) = cellfun(@euclideanDist, currFeatCellRep, otherFeatCell)';
end

fprintf('Set NaN values ...');
for i=1:size(features, 1)
    fprintf('i = %d\n', i);
    for j=1:size(features,1)
        % calculate distance only if the features originates from a different fold
        if allData.foldOrigin(i,1) == allData.foldOrigin(j,1)
            featDistances2(i,j) = NaN;
        end
    end
end

t = toc;
fprintf('time: %f', t);

%% example plot
amountNeighbors = 9;
for idxExampleImg = 1:20
    
    imgLocExample = allData.locations{idxExampleImg};
    
    [~, idx] = max(strcmp(allData.locations, imgLocExample));
    
    [sortedDistances, sortedIndices] = sort(featDistances(idx,:), 'ascend');
    
    closestImgs = sortedIndices(1:amountNeighbors);
    
    neighborLimited = floor(sqrt(amountNeighbors));
    
    figure;
    subplot(neighborLimited+1,neighborLimited,1);
    imshow(imgLocExample);
    title({...
        'predicted image';...
        sprintf('class: %s', allData.classLabels(idxExampleImg,:));...
        sprintf('fold: %d', allData.foldOrigin(idxExampleImg))});
    
    for i=1:neighborLimited^2
        subplot(neighborLimited+1,neighborLimited,neighborLimited+i);
        imshow(allData.locations{closestImgs(i)});
        title({...
            sprintf('class: %s', allData.classLabels(closestImgs(i),:));...
            sprintf('fold: %d', allData.foldOrigin(closestImgs(i)))});
    end
end
