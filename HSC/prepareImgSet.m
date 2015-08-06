function imgs = prepareImgSet(imgSet, params)

fprintf('Preparing image set "%s" ... ', inputname(1));

amountClasses = size(imgSet, 2);
imgs = cell(1,amountClasses);

reverseStr = '';
for i=1:amountClasses
        
    currentImgSet = imgSet(1,i);
    imgPerClass = cell(1,currentImgSet.Count);
    
    for j=1:currentImgSet.Count
        % read single image
        img = imread(currentImgSet.ImageLocation{1,j});
        % resize to 100x150 pixels
        imgResized = imresize(img, params.imgSize);
        % preprocess
        imgPrepro = preprocessImage(imgResized, params.patchSize);
        imgPerClass{1,j} = imgPrepro;
    end
    imgs{1,i} = imgPerClass;
    
    % display progress
    msg = sprintf('%d/%d', i, amountClasses);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
fprintf(' ... DONE!\n');
end