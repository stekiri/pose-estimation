% Script to experiment with image contrast.

imgSet = imageSet('/home/steffen/Dokumente/KITTI/experiments/cropped_images/easy/training', 'recursive');

imgMeans = zeros(imgSet.Count,1);
for i=1:imgSet.Count
    img = imread(imgSet.ImageLocation{1,i});
    imgMeans(i,1) = mean(mean(img));
end

figure;
hist(imgMeans, 30);

figure;
img = imread(imgSet.ImageLocation{1,1106});
subplot(4,1,1);
imshow(img);
title(sprintf('mean: %0.2f', mean(mean(img))));
subplot(4,1,2);
imshow(imadjust(img, [0 0.5],[]));
subplot(4,1,3);
imshow(imadjust(img, [0.25 0.75],[]));
subplot(4,1,4);
imshow(imadjust(img, [0.5 1],[]));

% Alternative script for contrast experiments

imgLocation = worstLocs{6,1};
[path, imgName, ext] = fileparts(imgLocation);


img = imread(imgLocation);

figure;
imshow(img)
imcontrast;

mean(mean(img))
var(double(im2col(img, [1 1],'distinct')))

imgAdj1 = imadjust(img, [0.25 0.75],[]);
imgAdj2 = imadjust(img, [0.2 0.65],[]);
imgAdj3 = imadjust(img, [0.5 1],[]);

figure;
subplot(4,1,1);
imshow(img);
subplot(4,1,2);
imshow(imgAdj1);
subplot(4,1,3);
imshow(imgAdj2);
subplot(4,1,4);
imshow(imgAdj3);

imgPrepro = imadjust(img, [0 0.65],[]);

backupLoc = '/home/steffen/Schreibtisch/backup_imgs';
copyfile(imgLocation, fullfile(backupLoc, strcat(imgName, ext)));

imwrite(imgPrepro, imgLocation);


imgEnl = imresize(img, 2);
figure;
imshow(img);

%% blabla

position = find(strcmp(imgLocation, worstLocs));
