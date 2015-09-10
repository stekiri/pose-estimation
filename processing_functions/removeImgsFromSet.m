function imgSet = removeImgsFromSet(imgSet, limit)
%removeImgsFromSet Remove images from an image set.
% Takes every i-th image from imgSet (i is defined by the variable 'ratio').

reverseStr = '';
amountClasses = size(imgSet,2);
for currClass = 1:amountClasses
    % remove images current class contains too many images
    amountImages = imgSet(1, currClass).Count;
    if amountImages > limit
        
        tempImgSet = imgSet(1, currClass);
        % take every x-th image from the image set (ratio = x)
        ratio = amountImages / limit;
        % use round to deal with uneven ratios
        tempImgSet = select(tempImgSet, round(1:ratio:amountImages));
        % make sure that there are really not too many images
        imgSet(1, currClass) = partition(tempImgSet, limit, 'sequential');
    end
    % display progress
    msg = sprintf('%d/%d\n', currClass, amountClasses);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

end