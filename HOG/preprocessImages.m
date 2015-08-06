function preprocessImages(inputFolder, outputFolder, params)

fprintf('Preprocessing images ... ');

mkdir(outputFolder);

imgSet = imageSet(inputFolder, 'recursive');

reverseStr = '';
for i=1:imgSet.Count
    
    imgLoc = imgSet.ImageLocation{1,i};
    [~, imgName, ext] = fileparts(imgLoc);
    img = imread(imgLoc);
    imgMean = mean(mean(img));
    if imgMean < 120
        imgModif = imadjust(img, [0 0.5],[]);
    else
        imgModif = imadjust(img, [0.5 1],[]);
    end
    newImgLoc = fullfile(outputFolder, strcat(imgName, ext));
    imwrite(imgModif, newImgLoc);
    
    % display progress
    msg = sprintf('%d/%d', i, imgSet.Count);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
fprintf(' ... DONE!\n');
end