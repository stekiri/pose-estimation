function splitDataIntoDrives(workFolder, imgFolder, outPath, recursive)

%% load random numbers
fileID = fopen(fullfile(workFolder, 'devkit/mapping/train_rand.txt'));
C = textscan(fileID,'%s');
fclose(fileID);

randomNumbersCell = strsplit(C{1,1}{1,1}, ',');
amountImages = size(randomNumbersCell, 2);

randomNumbers = zeros(amountImages,1);
for i=1:amountImages
    randomNumbers(i,1) = str2double(randomNumbersCell{1,i});
end

%% load the drives
fileID = fopen(fullfile(workFolder, 'devkit/mapping/train_mapping.txt'));
C = textscan(fileID,'%s %s %s');
fclose(fileID);

drives = zeros(amountImages, 1);
frames = zeros(amountImages, 1);
dates = cell(amountImages, 1);
for i=1:amountImages
    info = strsplit(C{1,2}{i,1}, '_');
    drives(i,1) = str2double(info{1,5});
    frames(i,1) = str2double(C{1,3}{i,1});
    dates{i,1} = C{1,1}{i,1};
end

%% assign each image to its drive

imgSet = imageSet(imgFolder, 'recursive');

for s=1:length(imgSet)

    if length(imgSet) == 1
        savePath = outPath;
    else
        savePath = fullfile(outPath, imgSet(1,s).Description);
    end
    
    mkdir(savePath)
    
    for i=1:imgSet(1,s).Count
        imgLoc = imgSet(1,s).ImageLocation{1,i};
        [~,imgName, ext] = fileparts(imgLoc);
        imgNumber = str2double(imgName);

        % look up the random number
        imgRandNumber = randomNumbers(imgNumber+1,1);

        % look up the associated properties of the image
        dateOfDrive = dates{imgRandNumber,1};
        drive       = drives(imgRandNumber,1);
        frame       = frames(imgRandNumber,1);

        % copy it to new folder
        newName = sprintf('%s-%04d-%010d-%06d', dateOfDrive, drive, frame, imgNumber);
        destFile = fullfile(savePath, strcat(newName, ext));
        copyfile(imgLoc, destFile);
    end
end

end