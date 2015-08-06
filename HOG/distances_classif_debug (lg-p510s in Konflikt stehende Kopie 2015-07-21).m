features = allFoldsData{1,1}.features;

featDistances = zeros(size(features,1));

for i=1:size(features, 1)
    x = features(i,:);
    for j=1:size(features,1)
        y = features(j,:);
        featDistances(i,j) = sqrt(sum((x-y).^2));
    end
end


[maxValue, maxIdx] = max(allResults{1,1}.cvResults{1,1}.probEstim, [], 2);


%%

[allData, ~] = mergeData(allFoldsData);

features = allData.features;

featDistances = zeros(size(features,1));

tic
for i=1:size(features, 1)
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

featDistances2 = zeros(size(features,1));

rows = repmat(1, 1, size(features,1));
featCell = mat2cell(features, rows, size(features,2));

tic
for i:1:size(features,1)
    currFeature = features(i,:);
    idx = setdiff(1:size(features,1), i);
    allOtherFeatures = features(idx, :);
    currFeatureRep = repmat(currFeature, size(allOtherFeatures, 1), 1);
    a = arrayfun(@euclideanDist, currFeatureRep, allOtherFeatures);