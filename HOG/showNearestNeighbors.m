function showNearestNeighbors(imgLocExample, aggregatedResults, featDistances, processParams, params)

titleFontSize = 7;
% merge to have all the data from the folds in one data object
% get the index of the image which should be compared
[~, idx] = max(strcmp(aggregatedResults{1,4}, imgLocExample));
% sort other images by the distance from selected image
[sortedDistances, sortedIndices] = sort(featDistances(idx,:), 'ascend');
% get the nearest neighbors
closestImgs = sortedIndices(1:params.neighbors);
% limit the amount of neighbors when non-quadratic number was chosen
neighborLimited = floor(sqrt(params.neighbors));

figure('units','normalized','outerposition',[0 0 1 1]);
% plot the selected image
subplot(neighborLimited+1,neighborLimited,1);
imshow(imgLocExample);
% get labels of image to display them in the title
predClassEx = getClassAssignment(aggregatedResults{1,1}(idx), processParams.classes);
truthClassEx = getClassAssignment(aggregatedResults{1,2}(idx), processParams.classes);
title({...
    'predicted image';...
%     sprintf('fold: %d', aggregatedResults{1,5}(idx));...
    sprintf('actual class: %02d', truthClassEx);...
    sprintf('predicted class: %02d', predClassEx)},...
    'FontSize', titleFontSize);

for i=1:neighborLimited^2
    subplot(neighborLimited+1,neighborLimited,neighborLimited+i);
    imshow(aggregatedResults{1,4}{closestImgs(i)});
    
    % get labels of image to display them in the title
    predClassNei = getClassAssignment(aggregatedResults{1,1}(closestImgs(i)), processParams.classes);
    truthClassNei = getClassAssignment(aggregatedResults{1,2}(closestImgs(i)), processParams.classes);
    
    % set color depending of positive or negative example
    if predClassEx == truthClassNei
        titleColor = 'green';
    elseif truthClassEx == truthClassNei
        titleColor = 'red';
    else
        titleColor = 'black';
    end
    
    title(...
        sprintf('actual class: %02d', truthClassNei),...
        'FontSize', titleFontSize, 'Color', titleColor);
    %         sprintf('predicted class: %02d', predClassNei);...
    %         sprintf('fold: %d', aggregatedResults{1,5}(closestImgs(i)))},...
end
end
