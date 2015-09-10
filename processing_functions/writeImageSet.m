function writeImageSet(imgSet, location, withSubStructure)
%writeImageSet Write an image set on the HDD.
% After removal of images from an image set it is necessary to save the
% image set in order to persist the new reduced image set.

% create directory
mkdir(location);

amountClasses = size(imgSet, 2);
fprintf('Write image set "%s" in folder ... ', inputname(1));
reverseStr = '';
for i = 1:amountClasses
    currImgSet = imgSet(1, i);
    if withSubStructure == true
        % create subfolder for classes
        folderName = currImgSet.Description;
        mkdir(location, folderName);
    end
    
    for j = 1:currImgSet.Count
        % get location of original image
        origFile = currImgSet.ImageLocation{1, j};
        % get name of original image
        [~, origFileName, ext] = fileparts(origFile);
        % set filepath+name of copied file
        if withSubStructure == true
            destinOfCopy = fullfile(location, folderName, strcat(origFileName, ext));
        else
            destinOfCopy = fullfile(location, strcat(origFileName, ext));
        end
        % copy the file
        copyfile(origFile, destinOfCopy);
    end
    % display progress
    msg = sprintf('%d/%d', i, amountClasses);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
    
end
fprintf(' ... DONE!\n');
end