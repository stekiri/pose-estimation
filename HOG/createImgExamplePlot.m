function imgLocations = createImgExamplePlot(dataCell, params)

% A:
% 1st row: estimate
% 2nd row: ground truth
% 3rd row: radian difference
A = cell2mat(dataCell(:,1:3));

% plot images with highest error
plotDim = ceil(sqrt(params.amountImages));

switch params.mode
    case 'worst'
        [B, I] = sort(A(:,3), 'descend');
    case 'best'
        [B, I] = sort(A(:,3), 'ascend');
end

f = figure('units','normalized','outerposition',[0 0 1 1]);
annotation('textbox', [0.2,0.9,0.1,0.1], 'String', params.description);

imgLocations = cell(params.amountImages, 1);
for k = 1:params.amountImages
    
    origRowNumber = I(k + params.startingPoint);
    imgLocations{k,1} = dataCell{1, 4}{origRowNumber, 1};
    subplot(plotDim, plotDim, k)
    img = imread(imgLocations{k,1});
    imshow(img)
    plotTitle = strcat('dev = ', num2str(B(k + params.startingPoint), '%0.2f'));
    title(plotTitle, 'FontSize', 6)
end

if params.print == true
    saveas(f, fullfile(params.saveLocation, strcat(params.plotName, '.jpg')));
end

end