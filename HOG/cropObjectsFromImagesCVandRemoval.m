function cropObjectsFromImagesCVandRemoval(imgDir, txtDir, outParentDir, ...
    outFolderName, params)

% create directory
mkdir(outParentDir, outFolderName);
% set output directory
outDir = fullfile(outParentDir, outFolderName);

% get the names of the folds
folderNames = getSubfolders(imgDir);

vehNumber = 0;

% perform cropping for training and test set
for m = 1:size(folderNames,1)
    currFolderName = folderNames{m,1};
    fprintf('Cropping object images from %s ... ', currFolderName);
    
    % create output file
    outputTxt = fopen(fullfile(outDir, strcat(currFolderName, '.txt')), 'w');
    
    % for every image in image set
    mkdir(outDir, currFolderName);
    currentPath = fullfile(imgDir, currFolderName);
    currentSet = imageSet(currentPath);
    
    [~, imgNames, ~] = cellfun(@fileparts, currentSet.ImageLocation, ...
        'UniformOutput', false);
    
    helpCell{1,1} = '-';
    imgProperties = cellfun(@strsplit, imgNames, repmat(helpCell, size(imgNames)), ...
        'UniformOutput', false);
    
    amountImages    = length(imgProperties);
    datesOfDr       = cell(amountImages, 1);
    drives          = zeros(amountImages, 1);
    frames          = zeros(amountImages, 1);
    imgNumbers      = zeros(amountImages, 1);
    
    for n=1:amountImages
        datesOfDr{n} = imgProperties{n}{1};
        drives(n) = str2double(imgProperties{n}{2});
        frames(n) = str2double(imgProperties{n}{3});
        imgNumbers(n) = str2double(imgProperties{n}{4});
    end
    
    uniqueDates = unique(datesOfDr);
    
    for d=1:length(uniqueDates)
        % select all images from one date
        currDate.dateOfDr   = uniqueDates(d);
        currDate.drives     = drives(strcmp(datesOfDr, uniqueDates(d)));
        currDate.frames     = frames(strcmp(datesOfDr, uniqueDates(d)));
        currDate.imgNumbers = imgNumbers(strcmp(datesOfDr, uniqueDates(d)));
        
        uniqueDrives = unique(currDate.drives);
        
        for r=1:length(uniqueDrives)
            % select all images from one drive
            currDrive.dateOfDr      = currDate.dateOfDr;
            currDrive.driveNumber   = uniqueDrives(r);
            currDrive.frames        = currDate.frames(currDate.drives == uniqueDrives(r));
            currDrive.imgNumbers    = currDate.imgNumbers(currDate.drives == uniqueDrives(r));
            currDrive.amountImages  = length(currDrive.frames);
            
            % lastRearImage depicts the frame number where the last rear image has been
            % cropped from. Initialize variable so that frame with number 0 is cropped at
            % beginning.
            lastRearImage = - params.removalFrequency;
            
            for i=1:currDrive.amountImages
                
                imgName = sprintf('%s-%04d-%010d-%06d.png', uniqueDates{d}, uniqueDrives(r),...
                    currDrive.frames(i), currDrive.imgNumbers(i));
                imgPath = fullfile(currentPath, imgName);
                
                % read corresponding txt file with annotations
                txtName = sprintf('%06d.txt', currDrive.imgNumbers(i));
                
                annotFile = fopen(fullfile(txtDir, txtName));
                Annot = textscan(annotFile, '%s %f %d %f %f %f %f %f %f %f %f %f %f %f %f');
                fclose(annotFile);
                
                % for every annotation in *.txt file
                for j = 1 : length(Annot{1})
                    
                    obj = extractAnnotation(Annot, j);
                    
                    [extract, newLastRearImage] = extractionCriteriaFullfilled(obj, params, ...
                        lastRearImage, currDrive.frames(i));
                    % Set the new frame number when an image from the rear was cropped.
                    % Stays the same if no image from the rear was cropped.
                    lastRearImage = newLastRearImage;
                    
                    if extract
                        
                        completeImg = imread(imgPath);
                        % crop image
                        croppingRectangle = [obj.bbox(1) obj.bbox(2) obj.width obj.height];
                        croppedImg = imcrop(completeImg, croppingRectangle);
                        
                        % convert to gray scale if desired
                        switch params.mode
                            case 'gray'
                                croppedImg = rgb2gray(croppedImg);
                        end
                        
                        % save image as [type]_[angle]_[imageNumber]_[occlusion]_[truncation].png
                        croppedName = sprintf('%s_%0.2f_%09d_%d_%0.2f.png', ...
                            obj.vehicleType, obj.angle, vehNumber, obj.occlusion, obj.truncation);
                        imwrite(croppedImg, fullfile(outDir, currFolderName, croppedName));
                        
                        % write information to txt file
                        fprintf(outputTxt, '%s %0.2f %09d %d %0.2f\n', ...
                            obj.vehicleType, obj.angle, vehNumber, obj.occlusion, obj.truncation);
                        
                        vehNumber = vehNumber + 1;
                    end
                end
            end
        end
    end
    fclose(outputTxt);
    fprintf(' ... DONE!\n');
end
end