function splitDataIntoFolds(amountFolds, workFolder, outPath)
%splitDataIntoFolds Split the data into folds.
% The data from all the drives is split into folds to enable leave-one-out
% cross-validation.

%% load random numbers
fileID = fopen(fullfile(workFolder, 'devkit/mapping/train_rand.txt'));
C = textscan(fileID,'%s');
fclose(fileID);

randomNumbersCell = strsplit(C{1,1}{1,1}, ',');
amountImages = size(randomNumbersCell, 2);

randomNumbers = zeros(amountImages,1);
for i=1:amountImages
    randomNumbers(i,1) = str2num(randomNumbersCell{1,i});
end

%% load the drives
fileID = fopen(fullfile(workFolder, 'devkit/mapping/train_mapping.txt'));
C = textscan(fileID,'%s %s %s');
fclose(fileID);

drives = [];
for i=1:amountImages
    info = strsplit(C{1,2}{i,1}, '_');
    drive = str2num(info{1,5});
    drives = [drives; drive];
end

%% equal number of images for all folds
% count number of images for each drive
driveMax = max(drives);
driveCounts = zeros(driveMax,1);
for i=1:driveMax
    driveCounts(i,1) = sum(drives == i);
end

%% fill folds with images

binSize = amountImages/amountFolds;

binSpaceLeft = repmat(binSize, 1, amountFolds);
% drivesInBin contains the drives which are assigned to the single bins
drivesInBin = cell(1, amountFolds);

driveAssigned = repmat(false, driveMax, 1);

leftoverDrives = [];

% sort in decreasing order
[sortedDriveCounts, sortIdx] = sort(driveCounts, 'descend');

currDrive = 1;
while currDrive <= driveMax
    for currBin=1:amountFolds
        if (driveAssigned(currDrive) == false) && ...
                (binSpaceLeft(currBin) > sortedDriveCounts(currDrive))
            
            drivesInBin{1,currBin} = [drivesInBin{1,currBin}; sortIdx(currDrive)];
            binSpaceLeft(currBin) = binSpaceLeft(currBin) - sortedDriveCounts(currDrive);
            driveAssigned(currDrive) = true;
        end
        
        if currBin == amountFolds && driveAssigned(currDrive) == false
            leftoverDrives = [leftoverDrives; sortIdx(currDrive)];
        end
    end
    currDrive = currDrive + 1;
end

% assign leftover drives to the bin which results in the lowest bin size violation
for i=1:size(leftoverDrives)
    violations = binSpaceLeft - driveCounts(leftoverDrives(i));
    [~, maxIdx] = max(violations);
    
    drivesInBin{1,maxIdx} = [drivesInBin{1,maxIdx}; leftoverDrives(i)];
    binSpaceLeft(maxIdx) = binSpaceLeft(maxIdx) - driveCounts(leftoverDrives(i));
end


%% sort images

imgSet = imageSet(fullfile(workFolder, 'image_2'), 'recursive');

for m=1:amountFolds
    imgLocations{1,m} = {};
end

for i=1:amountImages
    imgLoc = imgSet.ImageLocation{1,i};
    [~,imgName,~] = fileparts(imgLoc);
    imgNumber = str2num(imgName);
    
    % look up the random number
    imgRandNumber = randomNumbers(imgNumber+1,1);
    
    % look up to which drive it belongs
    driveNumber = drives(imgRandNumber,1);
    
    % check in which fold image belongs
    for j=1:amountFolds
        if sum(drivesInBin{1,j} == driveNumber) == 1
            imgLocations{1,j}{1,end+1} = imgLoc;
        end
    end
end

%% copy images into new folder

for n=1:amountFolds
    foldPath = fullfile(outPath, sprintf('fold_%02d',n));
    mkdir(foldPath);
    currImgLocations = imgLocations{1,n};
    for i=1:size(currImgLocations,2)
        sourceFile = currImgLocations{1,i};
        [imgPath, imgName, imgExt] = fileparts(sourceFile);
        destFile = fullfile(foldPath, strcat(imgName, imgExt));
        copyfile(sourceFile, destFile);
    end
end

end