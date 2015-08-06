function cropObjectsFromImagesCV(imgDir, txtDir, outParentDir, outFolderName, parameters)

% set parameters
objects     = parameters{1, 1};
occlThresh  = parameters{1, 2};
truncThresh = parameters{1, 3};
minImgSize  = parameters{1, 4};
mode        = parameters{1, 5};

% create directory
mkdir(outParentDir, outFolderName);
% set output directory
outDir = fullfile(outParentDir, outFolderName);

% get the names of the folds
folderNames = getSubfolders(imgDir);

k = 0;

% perform cropping for training and test set
for m = 1:size(folderNames,1)
    currFolderName = folderNames{m,1};
    fprintf('Cropping object images from %s ... ', currFolderName);
    % for every image in image set
    mkdir(outDir, currFolderName);
    currentSet = imageSet(fullfile(imgDir, currFolderName));
    % create output file
    outputTxt = fopen(fullfile(outDir, strcat(currFolderName, '.txt')), 'w');
    reverseStr ='';
    for i = 1:currentSet.Count
        
        imgPath = currentSet.ImageLocation{i};
        [~, imgName, ~] = fileparts(imgPath);
        % read corresponding txt file with annotations
        txtName = sprintf('%s.txt', imgName);
        
        annotFile = fopen(fullfile(txtDir, txtName));
        Annot = textscan(annotFile, '%s %f %d %f %f %f %f %f %f %f %f %f %f %f %f');
        fclose(annotFile);
        
        % for every annotation in *.txt file
        for j = 1 : length(Annot{1})
            
            vehicleType = Annot{1, 1}{j};
            occlusion = Annot{1, 3}(j);
            truncation = Annot{1, 2}(j);
            angle = Annot{1, 4}(j);
            
            % select specified objects and fully visible vehicles
            if (sum(strcmp(vehicleType, objects)) == 1) && ...
                    (occlusion <= occlThresh) &&  (truncation <= truncThresh)
                
                % bounding box defined with left, top, right, bottom coordinates
                bbox = [Annot{1, 5}(j) Annot{1, 6}(j) Annot{1, 7}(j) Annot{1, 8}(j)];
                % calculate width and height for cropping
                width = bbox(3) - bbox(1);
                height = bbox(4) - bbox(2);
                
                % crop image only if it's 'large enough'
                if (width >= minImgSize(2)) && (height >= minImgSize(1))
                    
                    completeImg = imread(imgPath);
                    % crop image
                    croppedImg = imcrop(completeImg, [bbox(1) bbox(2) width height]);
                    
                    % convert to gray scale if desired
                    switch mode
                        case 'gray'
                            croppedImg = rgb2gray(croppedImg);
                    end
                    
                    % save image as [type]_[angle]_[imageNumber]_[occlusion]_[truncation].png
                    croppedName = sprintf('%s_%0.2f_%09d_%d_%0.2f.png', ...
                        vehicleType, angle, k, occlusion, truncation);
                    imwrite(croppedImg, fullfile(outDir, currFolderName, croppedName));
                    
                    % write information to txt file
                    fprintf(outputTxt, '%s %0.2f %09d %d %0.2f\n', ...
                        vehicleType, angle, k, occlusion, truncation);
                    
                    k = k + 1;
                end
            end
        end
        % display progress
        msg = sprintf('%d/%d', i, currentSet.Count);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    fclose(outputTxt);
    fprintf(' ... DONE!\n');
end

end