function sortImagesIntoClasses(imgDir, outputDir, numClasses)
%sortImagesIntoClasses Sort images into classes.
% Sorts all cropped images from an directory into classes to make
% facilitate training for classification.

% create output directory
mkdir(outputDir);

folderNames = getSubfolders(imgDir);

[centers, classBounds] = calcCenterAndBoundsForClass(numClasses);

for m = 1:length(folderNames)
    fprintf('Sorting %s images into classes ... ', folderNames{m});
    currentImgSet = folderNames{m};
    % import image information from text file
    imgTxtData = fopen(fullfile(imgDir, strcat(currentImgSet, '.txt')));
    % structure of txt-file: [vehicleType] [angle] [imgNumber] [occlusion] [truncation]
    imgCell = textscan(imgTxtData, '%s %f %f %f %f');
    fclose(imgTxtData);
    
    % convert vehicle strings into numbers    
    helpVec = cellfun(@getVehicleNumber, imgCell{1,1});
    
    A = [helpVec cell2mat(imgCell(:,2:end))];
    
    % sort the images into appropriate class
    imgsPerClass = cell(numClasses, 1);
    for n = 1:numClasses
        % get all images belonging to the current class
        if n == numClasses
            % handle special case (for +-3.14)
            imgsPerClass{n, 1} = ...
                A((A(:,2) >= classBounds(n, 1) | A(:,2) < classBounds(n, 2)),:);
        else
            imgsPerClass{n, 1} = ...
                A((A(:,2) >= classBounds(n, 1) & A(:,2) < classBounds(n, 2)),:);
        end
    end
    
    % copy image into class folder
    reverseStr = '';
    for j = 1:numClasses
        
        classFolderName = sprintf('%02d_%+0.2f', j, centers(j));
        splitFolder = fullfile(outputDir, currentImgSet);
        mkdir(splitFolder, classFolderName);
        classFolder = fullfile(splitFolder, classFolderName);
        
        imgs = imgsPerClass{j, 1};
        
        for i = 1:size(imgs, 1)
            % image name: [type]_[angle]_[imageNumber]_[occlusion]_[truncation].png
            imgFileName = sprintf('%s_%0.2f_%09d_%d_%0.2f.png', ...
                getVehicleType(imgs(i,1)), imgs(i,2), imgs(i,3), imgs(i,4), imgs(i,5));
            
            origFile = fullfile(imgDir, currentImgSet, imgFileName);
            destFile = fullfile(classFolder, imgFileName);
            copyfile(origFile, destFile)
        end
        % display progress
        msg = sprintf('%d/%d', j, numClasses);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    fprintf(' ... DONE!\n');
end

end

function vehType = getVehicleType(number)

switch number
    case 0
        vehType = 'Car';
    case 1
        vehType = 'Van';
    case 2
        vehType = 'Truck';
    case 3
        vehType = 'Pedestrian';
    case 4
        vehType = 'Person_sitting';
    case 5
        vehType = 'Cyclist';
    case 6
        vehType = 'Tram';
    case 7
        vehType = 'Misc';
    case 8
        vehType = 'DontCare';
end
end

function vehNumber = getVehicleNumber(vehType)

switch vehType
    case 'Car'
        vehNumber = 0;
    case 'Van'
        vehNumber = 1;
    case 'Truck'
        vehNumber = 2;
    case 'Pedestrian'
        vehNumber = 3;
    case 'Person_sitting'
        vehNumber = 4;
    case 'Cyclist'
        vehNumber = 5;
    case 'Tram'
        vehNumber = 6;
    case 'Misc'
        vehNumber = 7;
    case 'DontCare'
        vehNumber = 8;
end
end