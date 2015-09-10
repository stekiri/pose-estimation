function equalizedImgSets = equalizeImageSet(imgSets, params)
amountClasses = size(imgSets, 2);
%equalizeImageSet Creates image sets of equal sizes.
% Mirroring of images to increase the number of images in small classes.
% Removal of images in large classes to make numer of images in all
% classes more equal.

fprintf('Equalize image set "%s" ... \n', inputname(1));
fprintf('* Mirror images for necessary classes ... ');
reverseStr = '';
for currClass = 1:amountClasses
    % mirror images if not enough images available
    if imgSets(1, currClass).Count < params.mirrorThreshold
        
        opposClass = getOppositeClassNumber(currClass, amountClasses);
        mirrorImages(imgSets(1, opposClass), currClass);
    end
    % display progress
    msg = sprintf('%d/%d\n', currClass, amountClasses);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

% reload image sets
setLocation = getParentDirectory(imgSets(1, 1).ImageLocation{1,1}, 2);
equalizedImgSets = imageSet(setLocation, 'recursive');

fprintf('* Remove images from classes if necessary ... ')
if params.removeThreshold < inf
    equalizedImgSets = removeImgsFromSet(equalizedImgSets, params.removeThreshold);
end
end


function mirrorImages(imgSet, smallClass)

for i = 1:imgSet.Count
    
    imgLoc = imgSet.ImageLocation{1, i};
    img = imread(imgLoc);
    mirroredImg = fliplr(img);
    
    % get properties of original image
    [type, angle, number, occlusion, truncation, ~, ~] = getImageProperties(imgLoc);
    % set properties of mirrored image
    mirrAngle = mirrorFun(angle);
    mirrNumber = - number;
    
    % get the parent directory
    [imgPath, ~, ~] = fileparts(imgLoc);
    parentDir = getParentDirectory(imgPath, 1);
    
    % list the folders to save image into correct folder
    listing = dir(parentDir);
    mirrFolderName = listing(smallClass + 2, 1).name;
    
    mirrFileName = sprintf('%s_%0.2f_%09d_%d_%0.2f.png', ...
        type, mirrAngle, mirrNumber, occlusion, truncation);
    imwrite(mirroredImg, fullfile(parentDir, mirrFolderName, mirrFileName));
end

end

function oppClNumber = getOppositeClassNumber(currClNumber, amountClasses)

if currClNumber < amountClasses/2
    if currClNumber <= amountClasses/4
        oppClNumber = currClNumber + 2*abs(1/4*amountClasses - currClNumber);
    else
        oppClNumber = currClNumber - 2*abs(1/4*amountClasses - currClNumber);
    end
else
    if currClNumber <= 3/4*amountClasses
        oppClNumber = currClNumber + 2*abs(3/4*amountClasses - currClNumber);
    else
        oppClNumber = currClNumber - 2*abs(3/4*amountClasses - currClNumber);
    end
end

end

function value = mirrorFun(x)

if x >= 0
    value = round(pi, 2) - x;
else
    value = - round(pi, 2) - x;
end

end